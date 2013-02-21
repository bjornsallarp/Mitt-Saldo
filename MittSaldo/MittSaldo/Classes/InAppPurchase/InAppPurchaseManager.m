//
//  Created by Björn Sållarp
//  NO Copyright. NO rights reserved.
//
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//  Follow me @bjornsallarp
//  Fork me @ http://github.com/bjornsallarp
//

#import "InAppPurchaseManager.h"

@interface InAppPurchaseManager()
@property (nonatomic, retain) SKProductsRequest *productsRequest;
@property (nonatomic, retain) SKProduct *lowPriceProduct;
@property (nonatomic, retain) SKProduct *midPriceProduct;
@property (nonatomic, retain) SKProduct *highPriceProduct;
@end

@implementation InAppPurchaseManager

+ (InAppPurchaseManager *)sharedManager
{
    static InAppPurchaseManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)loadStore
{
    if ([SKPaymentQueue canMakePayments] && !self.productsRequest) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [self requestProductData];        
    }
}

- (void)requestProductData
{
    NSSet *productIdentifiers = [NSSet setWithObjects:@"BuyLowPrice", @"BuyMidPrice", @"BuyHighPrice", nil];
    self.productsRequest = [[[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers] autorelease];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (BOOL)isReadyForPurchase
{
    return self.lowPriceProduct && self.midPriceProduct && self.highPriceProduct;
}

- (void)purchaseLowPrice
{
    SKPayment *payment = [SKPayment paymentWithProduct:self.lowPriceProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)purchaseMidPrice
{
    SKPayment *payment = [SKPayment paymentWithProduct:self.midPriceProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)purchaseHighPrice
{
    SKPayment *payment = [SKPayment paymentWithProduct:self.highPriceProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{  
    for (SKProduct *product in response.products) {
        if ([product.productIdentifier isEqualToString:@"BuyLowPrice"]) {
            self.lowPriceProduct = product;
        }
        else if ([product.productIdentifier isEqualToString:@"BuyMidPrice"]) {
            self.midPriceProduct = product;
        }
        else if ([product.productIdentifier isEqualToString:@"BuyHighPrice"]) {
            self.highPriceProduct = product;
        }
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        debug_NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    self.productsRequest = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error 
{
    debug_NSLog(@"We have a error in the request: %@", [error localizedDescription]);
    self.productsRequest = nil;
}

#pragma - Purchase helpers

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *transactions = [NSMutableArray array];
    NSArray *storedTransactions = [settings valueForKey:@"AppStoreTransactions"]; 
    
    if (storedTransactions) {
        [transactions addObjectsFromArray:storedTransactions];
    }
    
    [transactions addObject:transaction.transactionReceipt];
    [settings setValue:transactions forKey:@"AppStoreTransactions"];
    [settings synchronize];
}

- (void)showThankYouMessageForProductWithIdentifier:(NSString *)productId
{
    NSString *thankYouMessageKey = @"InAppPurchaseCompletedMessage";
    
    if ([productId isEqualToString:@"BuyMidPrice"]) {
        thankYouMessageKey = @"InAppPurchaseCompletedMessage";
    }
    else if ([productId isEqualToString:@"BuyHighPrice"]) {
        thankYouMessageKey = @"InAppPurchaseCompletedMessage";;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InAppPurchaseCompletedTitle", nil) 
                                                    message:NSLocalizedString(thankYouMessageKey, nil)
                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppPaid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self showThankYouMessageForProductWithIdentifier:transaction.payment.productIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:nil];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self showThankYouMessageForProductWithIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:nil];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InAppPurchaseFailedTitle", nil) 
                                                        message:[transaction.error localizedDescription] 
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InAppPurchaseCancelledTitle", nil) 
                                                        message:NSLocalizedString(@"InAppPurchaseCancelledMessage", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:nil];
}

#pragma mark - SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
