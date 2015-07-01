//
//  ViewController.m
//  RSA
//
//  Created by Tai Huu Ho on 6/24/15.
//  Copyright (c) 2015 Tai Huu Ho. All rights reserved.
//

#import "ViewController.h"
#import "RSA.h"


@interface ViewController ()
{
    RSA *rsa;
}

@property (weak, nonatomic) IBOutlet UITextView *plainText;
@property (weak, nonatomic) IBOutlet UILabel *encryptedValueLabel;

- (IBAction)didTouchedOnEncryptButton:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.plainText.layer.borderColor = [UIColor redColor].CGColor;
    self.plainText.layer.borderWidth = 1;
    
    rsa = [[RSA alloc] init];
    
    rsa.xmlPublicKeyPath = [[NSBundle mainBundle] pathForResource:@"sol.api.public" ofType:@"key"];
    NSLog(@"encrypted: %@", [rsa encrypt:@"Hồ Hữu Tài"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTouchedOnEncryptButton:(UIButton *)sender {
    if (self.plainText.text) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *encryptedValue = [rsa encrypt:self.plainText.text];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.encryptedValueLabel.text = encryptedValue;
            });
            
        });
    }
}
@end
