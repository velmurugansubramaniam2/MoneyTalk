#import "TGAttachmentSheetItemView.h"

@interface TGAttachmentSheetButtonItemView : TGAttachmentSheetItemView

@property (nonatomic, copy) void (^pressed)();

- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed;
- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed color:(UIColor *)color;
- (void)setTitle:(NSString *)title;
- (void)setBold:(bool)bold;
- (void)setImage:(UIImage *)image;
- (void)setDestructive:(bool)destructive;

- (void)_buttonPressed;

@end
