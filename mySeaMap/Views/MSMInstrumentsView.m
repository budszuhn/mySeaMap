//
//  MSMInstrumentsView.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 14.11.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMInstrumentsView.h"

@implementation MSMInstrumentsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
    
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = .7;
}

- (CGSize) intrinsicContentSize {
    return CGSizeMake(self.instrumentWidth, self.instrumentHeight);
}


@end
