#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wprotocol"
#pragma GCC diagnostic ignored "-Wmacro-redefined"
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wunknown-warning-option"
#pragma GCC diagnostic ignored "-Wincompatible-pointer-types"
#pragma GCC diagnostic ignored "-Wunused-value"
#pragma GCC diagnostic ignored "-Wunused-function"

@interface UIView (WATrans)
-(UIViewController *) nearestViewController;
-(NSMutableArray *) allSubViews;
@end
@implementation UIView (WATrans)
- (UIViewController *) nearestViewController {
  UIResponder *responder = self;
  while ([responder isKindOfClass:[UIView class]])
    responder = [responder nextResponder];
  return (UIViewController *)responder;
}

- (NSMutableArray *) allSubViews {
  NSMutableArray *arr= [[NSMutableArray alloc] init];
  [arr addObject:self];
  for (UIView *subview in self.subviews)
  {
    [arr addObjectsFromArray:(NSArray*)[subview allSubViews]];
  }
  return arr;
}

@end





#define rgbValue
#define UIColorFromHEX(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

 
static UIViewController *_topMostController(UIViewController *cont) {
    UIViewController *topController = cont;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
        }
        if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
        topController = visible;
        }
    }
 return (topController != cont ? topController : nil);
}


static UIViewController *topMostController(void) {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *next = nil;
    while ((next = _topMostController(topController)) != nil) {
    topController = next;
    }
    return topController;
}




@interface WAInputTextView : UITextView
@end 

@interface WAChatBar : NSObject
@property WAInputTextView *textView;
- (void)sendButtonTapped:(id)arg;
- (void)translateAndSendText:(NSString *)text fromLanguage:(NSString *)fromLang toLanguage:(NSString *)toLang;
@end 

@interface WAPhoneNumberUserJID : NSObject
@property NSString *obfuscatedJIDString;
@end 

@interface WAChatViewController : UIViewController 
+ (WAPhoneNumberUserJID *) currentlyActiveChatSessionJID;
- (void)reloadMessagesController:(BOOL)a1;
- (void) reloadAll;
- (void)reloadCellAfterReadMoreForMessage:(id)a1;
@end 



@interface WAMessage : NSObject
@property BOOL isTemplateMessage;
@property NSString *text;
@property BOOL isCommentMessage;
@property BOOL isFormMessage;
@end 


@interface WAMessageContainerView : UIView
@end


@interface WAMessageAttributedTextSlice : UIView 
@end 

@interface WAMessageAttributedTextSliceView : UIView 
@property (nonatomic, assign, readonly) WAMessageAttributedTextSlice *slice;
@end 


@interface WAMessageBubbleTableViewCell : UITableViewCell

- (void)translateText:(NSString *)text from:(NSString *)fromLang to:(NSString *)toLang;
- (void)showTranslationError;

@property (nonatomic, assign, readonly) WAMessage *focusedMessage;
@property WAMessageContainerView *containerView;


@end 
