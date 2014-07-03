//
//  SearchCell.h
//  SSSearchBarExample
//
//  Created by Hao Zheng on 7/2/14.
//  Copyright (c) 2014 Simon Gislen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *transLabel;

@property (weak, nonatomic) IBOutlet UILabel *queryLabel;
@end
