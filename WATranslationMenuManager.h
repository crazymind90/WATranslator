#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface WATranslationMenuManager : NSObject

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *languageMap;
@property (nonatomic, strong) NSString *userDefaultsKey;

- (instancetype)initWithUserDefaultsKey:(NSString *)key;
- (UIMenu *)createTranslationMenuWithTextProvider:(NSString *(^)(void))textProvider
                                  translationHandler:(void(^)(NSString *text, NSString *fromLang, NSString *toLang))handler
                                   restoreHandler:(void(^)(void))restoreHandler;
- (UIAction *)createLanguageAction:(NSString *)languageCode 
                      textProvider:(NSString *(^)(void))textProvider
                translationHandler:(void(^)(NSString *text, NSString *fromLang, NSString *toLang))handler;
- (NSMutableArray *)getRecentLanguages;
- (void)addToRecentLanguages:(NSString *)languageCode;

@end