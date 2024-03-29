//
//  AppDelegate.m
//  JooSoN
//
//  Created by 김학철 on 2019/12/29.
//  Copyright © 2019 김학철. All rights reserved.
//

#import "AppDelegate.h"
#import "TutorialViewController.h"
#import "RootNavigationController.h"
#import "MainViewController.h"
#import "UIView+Utility.h"
#import "UIView+Toast.h"
#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "LocationView.h"
#import "TermsViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) LocationView *locationView;

@end

@implementation AppDelegate

+ (AppDelegate *)instance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId] length] == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:MapIdGoogle forKey:SelectedMapId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        AppDelegate.instance.selMapId = MapIdGoogle;
    }
    else {
        AppDelegate.instance.selMapId = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedMapId];
    }
    
    //    [[NMFAuthManager shared] setClientId:NMFClientId];
    [GMSServices provideAPIKey:GoogleMapApiKey];
    [GMSPlacesClient provideAPIKey:GoogleMapApiKey];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    BOOL tutorialShow = [[NSUserDefaults standardUserDefaults] boolForKey:Tutorial_Once_Show];
    BOOL isShowTerms = [[NSUserDefaults standardUserDefaults] boolForKey:IsShowTerms];
    if (tutorialShow == NO) {
        [self callTutorialViewController];
    }
    else if (isShowTerms == NO) {
        [self callTermsViewContrller];
    }
    else {
        [self callMainViewController];
    }
    self.locationView = [[LocationView alloc] init];
    [_locationView startCurrentLocationUpdatingLocation];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [_locationView startCurrentLocationUpdatingLocation];
}
- (RootNavigationController *)rootNavigationController {
    MainViewController *mainViewController = (MainViewController *)[self.window rootViewController];
    return (RootNavigationController *)mainViewController.rootViewController;
}

- (void)callTutorialViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TutorialViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}
- (void)callTermsViewContrller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TermsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TermsViewController"];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window makeKeyAndVisible];
}
- (void)callMainViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    [vc setupWithType:1];
    RootNavigationController *rootNaviCon = [storyboard instantiateViewControllerWithIdentifier:@"RootNavigationController"];
    
    vc.rootViewController = rootNaviCon;
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)startIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView == nil) {
            self.loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.loadingView.backgroundColor = RGBA(0, 0, 0, 0.2);
        }
        
        [self.window addSubview:self.loadingView];
        [self.loadingView startAnimationWithRaduis:25];
    });
}
- (void)stopIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView) {
            [self.loadingView stopAnimation];
        }
        [self.loadingView removeFromSuperview];
    });
}

- (void)openSchemeUrl:(NSString *)urlStr completion:(void (^)(BOOL success))completion {
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *phoneUrl = [NSURL URLWithString:urlStr];
    UIApplication *application = [UIApplication sharedApplication];

    [application openURL:phoneUrl options:@{}
       completionHandler:^(BOOL success) {
        if (completion) {
            completion(success);
        }
    }];
}
- (void)openSchemeUrl:(NSString *)urlStr {
    
    if ([urlStr hasPrefix:@"tel"] || [urlStr hasPrefix:@"facetime"]) {
        
    }
    
    NSURL *phoneUrl = [NSURL URLWithString:urlStr];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:phoneUrl options:@{}
           completionHandler:^(BOOL success) {
            
        }];
    }
    else {
        [self.window makeToast:@"전화번호 형식이 아닙니다." duration:1.0 position:CSToastPositionTop];
    }
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"JooSoN"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


@end
