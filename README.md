Mitt Saldo v3
=============
This is the complete source code for [Mitt Saldo](http://blog.sallarp.com/mittsaldoitunes), a free multi banking app for iOS. The UI has been completely re-written and underlaying communication with banks/cards has ben totally re-engineered and improved.

Code details
============
A lot (almost everything) has changed since version 2. The really interesting parts of the code, the bank/card communication stuff, has been moved to a [separate repository](https://github.com/bjornsallarp/Mitt-Saldo-Library) to make it easier to re-use and maintain.

The app contains both non-free/copyrighted images and code. In the production app I use retina images bought from [Glyphish](http://www.glyphish.com/), I have excluded the retina images in this repo but the low-res free ones are still included.

I have also bougth the image-pack from [App-bits](http://app-bits.com/), the files are included in this repo but do note that they are licensed under CC Attribution-No-Derivs License.

The SDK for [Tactivo](http://www.idapps.com/) (the fingerprint reader, aka. Precise iOS Toolkit) is unfortunately not free and therefor those parts are grouped into a separate project inside the solution (MittSaldoTactivo). If you don't want to register and download their SDK in order to build:

* Remove the project MittSaldoTactivo from the solution
* Remove the preprocessor macro "Tactivo" from the build settings of MittSaldo-project
* Remove the header search paths for Tactivo  


#### Dependencies
* [Mitt Saldo Library](https://github.com/bjornsallarp/Mitt-Saldo-Library)
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD)

Optional

* [Precise iOS Toolkit](http://www.idapps.com/)

Installation / getting started
==============================
	git clone git@github.com:bjornsallarp/Mitt-Saldo.git
	cd Mitt-Saldo
	git submodule init
	git submodule update
	cd Vendor/Mitt-Saldo-Library
	git submodule init
	git submodule update
	
Copyright?
==========
No! No copyright. Take what you want and leave the rest. There might be some files that have the standard XCode copyright header, just ignore that. If the header mentions someone elses copyright or license, then it's not OK to ignore, but you probably realize that. If you build a super cool project with bits of my code please get in touch and let me know.

Author
======
It's just me, want to help out?

[@bjornsallarp](http://twitter.com/bjornsallarp) / [blog.sallarp.com](http://blog.sallarp.com) / bjorn.sallarp [at] gmail.com