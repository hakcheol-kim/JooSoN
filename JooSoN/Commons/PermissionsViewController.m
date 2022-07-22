//
//  PermissionsViewController.m
//  JooSoN
//
//  Created by 김학철 on 2021/02/19.
//  Copyright © 2021 김학철. All rights reserved.
//

#import "PermissionsViewController.h"
#import "IOSCheckPermissions.h"
#import "ContactsManager.h"
#import <CoreNFC/CoreNFC.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AppDelegate.h"

@interface PermissionsViewController () <CLLocationManagerDelegate, NFCNDEFReaderSessionDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnContacts;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnNfc;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnBluetooth;
@property (weak, nonatomic) IBOutlet UIButton *btnMicrophone;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NFCNDEFReaderSession *nfcSession;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation PermissionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [[IOSCheckPermissions globalInstance] enableCheckPermissionLogs:YES];
    _btnNfc.hidden = YES;
    _btnMicrophone.hidden = YES;
    [self decorationUi];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)decorationUi {
    
    UILabel *lbDes = [_btnContacts viewWithTag:102];
    lbDes.text = [[NSBundle mainBundle] localizedStringForKey:@"NSContactsUsageDescription" value:nil table:@"InfoPlist"];
    
    lbDes = [_btnLocation viewWithTag:102];
    lbDes.text = [[NSBundle mainBundle] localizedStringForKey:@"NSLocationWhenInUseUsageDescription" value:nil table:@"InfoPlist"];
    
    lbDes = [_btnCamera viewWithTag:102];
    lbDes.text = [[NSBundle mainBundle] localizedStringForKey:@"NSCameraUsageDescription" value:nil table:@"InfoPlist"];
    
    lbDes = [_btnBluetooth viewWithTag:102];
    lbDes.text = [[NSBundle mainBundle] localizedStringForKey:@"NSBluetoothAlwaysUsageDescription" value:nil table:@"InfoPlist"];
}
- (IBAction)onClickedBtnActions:(UIButton *)sender {
    if (sender == _btnNext) {
        if (_btnContacts.selected == NO) {
            [self checkPermissionContacts];
            return;
        }
        else if (_btnLocation.selected == NO) {
            [self checkPermissionLocation];
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsShowTerms];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[AppDelegate instance] callMainViewController];
        
    }
    else if (sender == _btnContacts) {
        [self checkPermissionContacts];
    }
    else if (sender == _btnLocation) {
        [self checkPermissionLocation];
    }
    else if (sender == _btnCamera) {
        [self checkPermissionCamera];
    }
    else if (sender == _btnNfc) {
        [self checkPermissionNfc];
    }
    else if (sender == _btnBluetooth) {
        [self checkPermissionBluetooth];
    }
    else if (sender == _btnMicrophone) {
        [self checkPermissionMicrophone];
    }
    else if (sender == _btnBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)checkPermissionContacts {
    [ContactsManager checkContactWidthCompetion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                UILabel *lbTitle = [self.btnContacts viewWithTag:101];
                lbTitle.textColor = [UIColor yellowColor];
                self.btnContacts.selected = YES;
            }
            else {
                NSDictionary *userInfo = error.userInfo;
                if (userInfo != nil && [[userInfo objectForKey:@"msg"] isEqualToString:@"CNAuthorizationStatusDenied"]) {
                 
                    [self showSettingAlert:@"연락처에 액세스 할 수 없습니다." msg:@"액세스를 활성화하려면 설정> 개인 정보> 연락처로 이동하여이 앱에 대한 연락처 액세스를 켜십시오."];
                }
            }
        });
    }];
}

- (void)checkPermissionLocation {
    __weak typeof(self) weakSelf = self;
    [[IOSCheckPermissions globalInstance] checkPermissionAccessForLocation: AuthorizeRequestTypeWhenInUseAuthorization
                                                              successBlock:^{
        [weakSelf.locationManager startUpdatingLocation];
        UILabel *lbTitle = [self.btnLocation viewWithTag:101];
        lbTitle.textColor = [UIColor yellowColor];
        self.btnLocation.selected = YES;
    } failureBlock:^{
        [weakSelf showSettingAlert:@"위치에 액세스 할 수 없습니다." msg:@"액세스를 사용하려면 설정> 개인 정보 보호> 위치로 이동하여이 앱의 연락처 액세스를 사용 설정하세요."];
    }];
}
- (void)checkPermissionCamera {
    __weak typeof(self) weakSelf = self;
    
    [[IOSCheckPermissions globalInstance] checkPermissionAccessForGallery:^{
        UILabel *lbTitle = [self.btnCamera viewWithTag:101];
        lbTitle.textColor = [UIColor yellowColor];
        self.btnCamera.selected = YES;
    } failureBlock:^{
        [weakSelf showSettingAlert:@"카메라 및 캘러리에 액세스 할 수 없습니다." msg:@"액세스를 사용하려면 설정> 개인 정보 보호> 사진으로 이동하여이 앱의 캘러리 액세스를 사용 설정하세요."];
    }];
}
- (void)checkPermissionNfc {
    self.nfcSession = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                               queue:dispatch_queue_create(NULL,
                                                                           DISPATCH_QUEUE_CONCURRENT)
                            invalidateAfterFirstRead:NO];
    
        
}
     
- (void)checkPermissionBluetooth {
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}
- (void)checkPermissionMicrophone {
    
}

- (void)showSettingAlert:(NSString *)title msg:(NSString *)msg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:title
                                                                          message:msg
                                                                   preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertCon dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertCon addAction:okAction];
        
        UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsUrl]) {
                [[UIApplication sharedApplication] openURL:settingsUrl options:@{} completionHandler:nil];
            }
            else {
                [alertCon dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [alertCon addAction:settingAction];
        [self presentViewController:alertCon animated:YES completion:nil];
    });
}


#pragma mark - CLLocationManagerDelegate
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([locations count] > 0) {
        NSLog(@"-->> User CLLocationManagerDelegate -->  %@",[locations[0] description]);
    }
}

#pragma mark - NFCNDEFReaderSessionDelegate
- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error {
        int k = 0;
}

#pragma CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"state :%d", central.state);
        switch (central.state) {
            case CBManagerStateUnauthorized: {
                if (CBManager.authorization == CBManagerAuthorizationNotDetermined)  {
                    
                }
                else if (CBManager.authorization == CBManagerAuthorizationDenied) {
                    [self showSettingAlert:@"블루트스에 액세스 할 수 없습니다." msg:@"액세스를 사용하려면 설정> 개인 정보 보호> 위치로 이동하여이 앱의 블루트스 액세스를 사용 설정하세요."];
                }
                else if (CBManager.authorization == CBManagerAuthorizationAllowedAlways) {
                }
                else if (CBManager.authorization == CBManagerAuthorizationRestricted) {
                    
                }
                break;
            }
            case CBManagerStatePoweredOn: {
                UILabel *lbTitle = [self.btnBluetooth viewWithTag:101];
                lbTitle.textColor = [UIColor yellowColor];
                self.btnBluetooth.selected = YES;
                [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
                break;
            }
            default:
                break;
                
        }
    });
}

@end
