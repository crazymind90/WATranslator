// By @CrazyMind90

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WATranslationMenuManager.h"
#import "WAHeaders.h"

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




%hook WAChatBar
- (void) setupSendButton {
    %orig;

    UIButton *_sendButton = [self valueForKey:@"_sendButton"];
    
    WATranslationMenuManager *menuManager = [[WATranslationMenuManager alloc] initWithUserDefaultsKey:@"RecentChatBarTranslationLanguages"];
    
    UIMenu *translationMenu = [menuManager createTranslationMenuWithTextProvider:^NSString *{
        return self.textView.text;
    } translationHandler:^(NSString *text, NSString *fromLang, NSString *toLang) {

        [self translateAndSendText:text fromLanguage:fromLang toLanguage:toLang];
    } restoreHandler:nil];
    
    UIAction *sendAction = [UIAction actionWithTitle:@"Send" 
                                            image:[UIImage systemImageNamed:@"paperplane.fill"] 
                                        identifier:nil 
                                            handler:^(__kindof UIAction * _Nonnull action) {
        [self sendButtonTapped:_sendButton];
    }];
    
    NSMutableArray *menuItems = [translationMenu.children mutableCopy];
    [menuItems addObject:sendAction];
    
    UIMenu *mainMenu = [UIMenu menuWithTitle:@"" 
                                    children:menuItems];
    
    _sendButton.menu = mainMenu;
    _sendButton.showsMenuAsPrimaryAction = YES;
}

%new
- (void)translateAndSendText:(NSString *)text fromLanguage:(NSString *)fromLang toLanguage:(NSString *)toLang {
    NSCharacterSet *nsset = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *getEncoded = [text stringByAddingPercentEncodingWithAllowedCharacters:nsset];

    NSString *link = [NSString stringWithFormat:@"https://translate.googleapis.com/translate_a/single?client=gtx&sl=%@&tl=%@&dt=t&q=%@", fromLang, toLang, getEncoded];

    NSURL *url = [NSURL URLWithString:link];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) { 
                NSError *error;
                NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                
                if (!error && result.count > 0) {
                    NSArray *translations = result[0];
                    if (translations.count > 0) {

                        NSMutableString *fullTranslation = [[NSMutableString alloc] init];
                        
                        for (NSArray *translationSegment in translations) {
                            if ([translationSegment isKindOfClass:[NSArray class]] && translationSegment.count > 0) {
                                NSString *segmentText = translationSegment[0];
                                if ([segmentText isKindOfClass:[NSString class]]) {
                                    [fullTranslation appendString:segmentText];
                                }
                            }
                        }
                        
                        NSString *translated = [fullTranslation copy];
                        self.textView.text = translated;
                    }
                }
            }

            UIButton *_sendButton = [self valueForKey:@"_sendButton"];
            [self sendButtonTapped:_sendButton];
        });
    });
}
%end


static WAMessage *_gMsg;
static WATranslationMenuManager *messageCellMenuManager;

%hook WAMessageBubbleTableViewCell

- (void)layoutSubviews {
    %orig;
    
    if (!self.focusedMessage.text) return;
    
    if ([self.contentView viewWithTag:9999]) {

        [[self.contentView viewWithTag:9999] removeFromSuperview];
    }
    
    if (self.subviews.count == 0) return;
    if (self.subviews[0].subviews.count == 0) return;
    
    UIView *chatBubble = self.subviews[0].subviews[0];
    CGFloat bubbleCenterX = CGRectGetMidX(chatBubble.frame);
    CGFloat cellWidth = self.frame.size.width;
    CGFloat cellCenterX = cellWidth / 2.0;
    BOOL isFromMe = bubbleCenterX > cellCenterX;
    

    if (!messageCellMenuManager) {
        messageCellMenuManager = [[WATranslationMenuManager alloc] initWithUserDefaultsKey:@"RecentMessageTranslationLanguages"];
    }
    
    UIButton *translateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    translateButton.tag = 9999;
    UIImage *translateImage = [UIImage systemImageNamed:@"globe"];
    [translateButton setImage:translateImage forState:UIControlStateNormal];
    translateButton.tintColor = [UIColor colorWithWhite:0.2 alpha:0.7];
    translateButton.translatesAutoresizingMaskIntoConstraints = NO;
    translateButton.showsMenuAsPrimaryAction = YES;
    

    translateButton.menu = [messageCellMenuManager createTranslationMenuWithTextProvider:^NSString *{
        return self.focusedMessage.text;
    } translationHandler:^(NSString *text, NSString *fromLang, NSString *toLang) {
        _gMsg = self.focusedMessage;
        [self translateText:text from:fromLang to:toLang];
        

        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *oldButton = [self.contentView viewWithTag:9999];
            if (oldButton) {
                [oldButton removeFromSuperview];
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }
        });
    } restoreHandler:^{

        NSString *originalText = self.focusedMessage.text;
        NSString *translationMarker = @"~[Translation] :";
        if ([originalText containsString:translationMarker]) {
            NSRange markerRange = [self.focusedMessage.text rangeOfString:translationMarker];
            originalText = [self.focusedMessage.text substringToIndex:markerRange.location];
            self.focusedMessage.text = [originalText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            WAChatViewController *chatController = self.nearestViewController;
            [chatController reloadCellAfterReadMoreForMessage:self.focusedMessage];
        }
    }];
    
    [self.contentView addSubview:translateButton];
    
    if (isFromMe) {
        [NSLayoutConstraint activateConstraints:@[
            [translateButton.leadingAnchor constraintEqualToAnchor:chatBubble.leadingAnchor constant:-40],
            [translateButton.centerYAnchor constraintEqualToAnchor:chatBubble.centerYAnchor constant:0],
            [translateButton.widthAnchor constraintEqualToConstant:30],
            [translateButton.heightAnchor constraintEqualToConstant:30]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [translateButton.trailingAnchor constraintEqualToAnchor:chatBubble.trailingAnchor constant:40],
            [translateButton.centerYAnchor constraintEqualToAnchor:chatBubble.centerYAnchor constant:0],
            [translateButton.widthAnchor constraintEqualToConstant:30],
            [translateButton.heightAnchor constraintEqualToConstant:30]
        ]];
    }
}

%new
- (void)translateText:(NSString *)text from:(NSString *)fromLang to:(NSString *)toLang {
    __block NSString *__text = text;
    NSString *translationMarker = @"~[Translation] :";

    __block NSString *originalText = text;
    if ([originalText containsString:translationMarker]) {
        NSRange markerRange = [__text rangeOfString:translationMarker];
        originalText = [__text substringToIndex:markerRange.location];
        originalText = [originalText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }

    NSCharacterSet *nsset = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *getEncoded = [originalText stringByAddingPercentEncodingWithAllowedCharacters:nsset];

    
    NSString *link = [NSString stringWithFormat:@"https://translate.googleapis.com/translate_a/single?client=gtx&sl=%@&tl=%@&dt=t&q=%@", fromLang, toLang, getEncoded];

    NSURL *url = [NSURL URLWithString:link];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) { 
                NSError *error;
                NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!error && result.count > 0) {
                    NSArray *translations = result[0];
                    if (translations.count > 0) {

                        NSMutableString *fullTranslation = [[NSMutableString alloc] init];
                        
                        for (NSArray *translationSegment in translations) {
                            if ([translationSegment isKindOfClass:[NSArray class]] && translationSegment.count > 0) {
                                NSString *segmentText = translationSegment[0];
                                if ([segmentText isKindOfClass:[NSString class]]) {
                                    [fullTranslation appendString:segmentText];
                                }
                            }
                        }
                        
                        NSString *translated = [fullTranslation copy];

                        NSString *translationMarker = @"~[Translation] :";
                        NSString *finalText;

                        if ([__text containsString:translationMarker]) {
                            NSRange markerRange = [__text rangeOfString:translationMarker];
                            NSString *originalText = [__text substringToIndex:markerRange.location];
                            originalText = [originalText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                            finalText = [NSString stringWithFormat:@"%@\n\n~[Translation] :\n%@", originalText, translated];
                        } else {
                            finalText = [NSString stringWithFormat:@"%@\n\n~[Translation] :\n%@", __text, translated];
                        }

                        _gMsg.text = finalText;

                        WAChatViewController *chatController = self.nearestViewController;
                        [chatController reloadCellAfterReadMoreForMessage:_gMsg];
                    }
                }
            } else {
                [self showTranslationError];
            }
        });
    });
}

%new
- (void)showTranslationError {
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Translation Error" 
                                                                        message:@"Failed to translate message" 
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" 
                                                       style:UIAlertActionStyleDefault 
                                                     handler:nil];
    [errorAlert addAction:okAction];
    
    UIViewController *topController = topMostController();
    [topController presentViewController:errorAlert animated:YES completion:nil];
}

%end