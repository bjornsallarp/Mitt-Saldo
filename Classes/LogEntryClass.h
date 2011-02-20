
#import <Foundation/Foundation.h>
@interface LogEntryClass : NSObject {
	NSString *Content;
	NSDate *DateAdded;
	NSString *Bank;
}

@property (nonatomic, retain) NSString * Content;
@property (nonatomic, retain) NSDate * DateAdded;
@property (nonatomic, retain) NSString * Bank;


-(void)appendStep:(NSString*)stepName logContent:(NSString*)logContent;
@end