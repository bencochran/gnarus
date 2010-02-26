//
//  HUDView.h
//  gnarus
//
//  Created by Ben Cochran on 2/23/10.
//
//  Inspired by http://github.com/jdg/MBProgressHUD
//	which has the following license:
//
//	Copyright (c) 2009 Matej Bukovinski
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import <UIKit/UIKit.h>

typedef enum {
	HUDViewStyleSpinner,
	HUDViewStyleError
} HUDViewStyle;

@interface HUDView : UIView {
	HUDViewStyle _style;
	
	UILabel *_statusLabel;
	UILabel *_statusDetailsLabel;
	
	NSString *_status;
	NSString *_statusDetails;
	
	UIView *_indicator;
	
	CGFloat _height;
	CGFloat _width;
	
	BOOL touched;
}

+ (void)showHUDStyle:(HUDViewStyle)style status:(NSString *)status statusDetails:(NSString *)statusDetails;
+ (void)showHUDStyle:(HUDViewStyle)style status:(NSString *)status statusDetails:(NSString *)statusDetails forTime:(NSTimeInterval)time;
+ (void)dismiss;

@end