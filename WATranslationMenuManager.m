#import "WATranslationMenuManager.h"


@implementation WATranslationMenuManager

- (instancetype)initWithUserDefaultsKey:(NSString *)key {
    self = [super init];
    if (self) {
        self.userDefaultsKey = key;
        [self initializeLanguageSystem];
    }
    return self;
}

- (void)initializeLanguageSystem {

    self.languageMap = @{
        @"ar": @"Arabic",
        @"en": @"English",
        @"es": @"Spanish",
        @"fr": @"French",
        @"de": @"German",
        @"it": @"Italian",
        @"pt": @"Portuguese",
        @"ru": @"Russian",
        @"ja": @"Japanese",
        @"ko": @"Korean",
        @"zh": @"Chinese",
        @"hi": @"Hindi",
        @"tr": @"Turkish",
        @"nl": @"Dutch",
        @"sv": @"Swedish",
        @"da": @"Danish",
        @"no": @"Norwegian",
        @"fi": @"Finnish",
        @"pl": @"Polish",
        @"cs": @"Czech",
        @"hu": @"Hungarian",
        @"ro": @"Romanian",
        @"bg": @"Bulgarian",
        @"hr": @"Croatian",
        @"sk": @"Slovak",
        @"sl": @"Slovenian",
        @"et": @"Estonian",
        @"lv": @"Latvian",
        @"lt": @"Lithuanian",
        @"mt": @"Maltese",
        @"ga": @"Irish",
        @"cy": @"Welsh",
        @"is": @"Icelandic",
        @"mk": @"Macedonian",
        @"sq": @"Albanian",
        @"sr": @"Serbian",
        @"bs": @"Bosnian",
        @"me": @"Montenegrin",
        @"uk": @"Ukrainian",
        @"be": @"Belarusian",
        @"ka": @"Georgian",
        @"hy": @"Armenian",
        @"az": @"Azerbaijani",
        @"kk": @"Kazakh",
        @"ky": @"Kyrgyz",
        @"uz": @"Uzbek",
        @"tj": @"Tajik",
        @"mn": @"Mongolian",
        @"th": @"Thai",
        @"vi": @"Vietnamese",
        @"lo": @"Lao",
        @"km": @"Khmer",
        @"my": @"Myanmar",
        @"si": @"Sinhala",
        @"ta": @"Tamil",
        @"te": @"Telugu",
        @"kn": @"Kannada",
        @"ml": @"Malayalam",
        @"bn": @"Bengali",
        @"gu": @"Gujarati",
        @"pa": @"Punjabi",
        @"or": @"Odia",
        @"as": @"Assamese",
        @"ur": @"Urdu",
        @"fa": @"Persian",
        @"ps": @"Pashto",
        @"he": @"Hebrew",
        @"yi": @"Yiddish",
        @"am": @"Amharic",
        @"ti": @"Tigrinya",
        @"om": @"Oromo",
        @"so": @"Somali",
        @"sw": @"Swahili",
        @"zu": @"Zulu",
        @"xh": @"Xhosa",
        @"af": @"Afrikaans",
        @"ig": @"Igbo",
        @"yo": @"Yoruba",
        @"ha": @"Hausa",
        @"mg": @"Malagasy",
        @"ny": @"Chichewa",
        @"sn": @"Shona",
        @"st": @"Sesotho",
        @"tn": @"Setswana",
        @"ts": @"Xitsonga",
        @"ss": @"Siswati",
        @"ve": @"Tshivenda",
        @"nr": @"Ndebele"
    };
}

- (NSMutableArray *)getRecentLanguages {
    NSArray *saved = [[NSUserDefaults standardUserDefaults] arrayForKey:self.userDefaultsKey];
    return saved ? [saved mutableCopy] : [NSMutableArray array];
}

- (void)addToRecentLanguages:(NSString *)languageCode {
    NSMutableArray *recent = [self getRecentLanguages];
    

    [recent removeObject:languageCode];
    

    [recent insertObject:languageCode atIndex:0];
    

    while (recent.count > 3) {
        [recent removeLastObject];
    }
    

    [[NSUserDefaults standardUserDefaults] setObject:[recent copy] forKey:self.userDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIAction *)createLanguageAction:(NSString *)languageCode 
                      textProvider:(NSString *(^)(void))textProvider
                translationHandler:(void(^)(NSString *text, NSString *fromLang, NSString *toLang))handler {
    NSString *languageName = self.languageMap[languageCode] ?: languageCode;
    
    return [UIAction actionWithTitle:languageName
                               image:nil
                          identifier:nil
                             handler:^(__kindof UIAction * _Nonnull action) {
        NSString *textToTranslate = textProvider();
        if (textToTranslate && textToTranslate.length > 0) {
            handler(textToTranslate, @"auto", languageCode);
            [self addToRecentLanguages:languageCode];
        }
    }];
}

- (UIMenu *)createTranslationMenuWithTextProvider:(NSString *(^)(void))textProvider
                               translationHandler:(void(^)(NSString *text, NSString *fromLang, NSString *toLang))handler
                                   restoreHandler:(void(^)(void))restoreHandler {
    NSMutableArray<UIMenuElement *> *menuItems = [NSMutableArray array];
    

    NSMutableArray *currentRecent = [self getRecentLanguages];
    

    if (currentRecent.count > 0) {
        for (NSString *langCode in currentRecent) {
            [menuItems addObject:[self createLanguageAction:langCode textProvider:textProvider translationHandler:handler]];
        }
    }
    

    NSMutableArray<UIMenuElement *> *europeanLanguages = [NSMutableArray array];
    NSMutableArray<UIMenuElement *> *asianLanguages = [NSMutableArray array];
    NSMutableArray<UIMenuElement *> *africanLanguages = [NSMutableArray array];
    
    NSArray *europeanCodes = @[@"en", @"es", @"fr", @"de", @"it", @"pt", @"ru", @"nl", @"sv", @"da", @"no", @"fi", @"pl", @"cs", @"hu", @"ro", @"bg", @"hr", @"sk", @"sl", @"et", @"lv", @"lt", @"mt", @"ga", @"cy", @"is", @"mk", @"sq", @"sr", @"bs", @"me", @"uk", @"be"];
    NSArray *asianCodes = @[@"ja", @"ko", @"zh", @"hi", @"tr", @"th", @"vi", @"lo", @"km", @"my", @"si", @"ta", @"te", @"kn", @"ml", @"bn", @"gu", @"pa", @"or", @"as", @"ur", @"fa", @"ps", @"ka", @"hy", @"az", @"kk", @"ky", @"uz", @"tj", @"mn"];
    NSArray *africanCodes = @[@"ar", @"he", @"yi", @"am", @"ti", @"om", @"so", @"sw", @"zu", @"xh", @"af", @"ig", @"yo", @"ha", @"mg", @"ny", @"sn", @"st", @"tn", @"ts", @"ss", @"ve", @"nr"];
    

    for (NSString *langCode in [europeanCodes sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [self.languageMap[a] compare:self.languageMap[b]];
    }]) {
        if (self.languageMap[langCode]) {
            [europeanLanguages addObject:[self createLanguageAction:langCode textProvider:textProvider translationHandler:handler]];
        }
    }
    
    for (NSString *langCode in [asianCodes sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [self.languageMap[a] compare:self.languageMap[b]];
    }]) {
        if (self.languageMap[langCode]) {
            [asianLanguages addObject:[self createLanguageAction:langCode textProvider:textProvider translationHandler:handler]];
        }
    }
    
    for (NSString *langCode in [africanCodes sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [self.languageMap[a] compare:self.languageMap[b]];
    }]) {
        if (self.languageMap[langCode]) {
            [africanLanguages addObject:[self createLanguageAction:langCode textProvider:textProvider translationHandler:handler]];
        }
    }
    

    UIMenu *moreLanguagesMenu = [UIMenu menuWithTitle:@"More Languages"
                                                image:[UIImage systemImageNamed:@"globe"]
                                           identifier:nil
                                              options:0
                                             children:@[
        [UIMenu menuWithTitle:@"European" image:[UIImage systemImageNamed:@"flag"] identifier:nil options:UIMenuOptionsDisplayInline children:europeanLanguages],
        [UIMenu menuWithTitle:@"Asian" image:[UIImage systemImageNamed:@"flag"] identifier:nil options:UIMenuOptionsDisplayInline children:asianLanguages],
        [UIMenu menuWithTitle:@"African & Middle Eastern" image:[UIImage systemImageNamed:@"flag"] identifier:nil options:UIMenuOptionsDisplayInline children:africanLanguages]
    ]];
    
    [menuItems addObject:moreLanguagesMenu];
    

    if (restoreHandler) {
        UIAction *restoreAction = [UIAction actionWithTitle:@"Restore MSG"
                                                      image:[UIImage systemImageNamed:@"arrow.counterclockwise"]
                                                 identifier:nil
                                                    handler:^(__kindof UIAction * _Nonnull action) {
            restoreHandler();
        }];
        [menuItems addObject:restoreAction];
    }
    
    return [UIMenu menuWithTitle:@"WATranslator"
                           image:[UIImage systemImageNamed:@"textformat"]
                      identifier:nil
                         options:0
                        children:menuItems];
}

@end
