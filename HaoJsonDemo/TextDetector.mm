//
//  TextDetector.m
//  EdibleCameraApp
//
//  Created by MEI C on 5/23/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "TextDetector.h"
#include <fstream>
#include <vector>
#import <opencv2/opencv.hpp>
#include "UIImage+OpenCV.h"
#include  <opencv2/imgproc.hpp>
#include  <opencv2/objdetect.hpp>
#include  <opencv2/highgui.hpp>

#define CLASSIFIER1 "test.txt"
#define CLASSIFIER2 ""
#define GROUPING ""

using namespace cv;
using namespace std;

@implementation TextDetector

//Return a UIImage with its text regions marked
+(UIImage *)detectTextRegions:(UIImage *)orgImg{
    NSLog(@"DetectText Function called!");
    
    //Initialize original Mat for text detection
    Mat orgMat = [orgImg CVMat8UC3];

    //Detect text groups
    vector<cv::Rect> groups;
    [self textRegionsOfC3Mat:orgMat withGroups:groups];
    
    //Draw the groups on the Mat
    [self groupsDrawWithMat:orgMat andGroups:groups];
    [self textGroupsSortAndMerge:groups];
    //Convert Mat to UIImage
    UIImage *result = [UIImage imageWithCVMat:orgMat];
    
    // Memory clean-up
    if (!groups.empty())
    {
        groups.clear();
    }
    
    return result;
}

//Detect the text regions from a 8UC3 Mat
+(void) textRegionsOfC3Mat:(Mat)orgMat withGroups:(vector<cv::Rect> &)groups{
    
    NSLog(@"DetectTextRect Function called!");
    
    //Extract channels to be processed individually
    vector<Mat> channels;
    computeNMChannels(orgMat, channels, ERFILTER_NM_RGBLGrad);
    int cn = (int)channels.size();
    
    NSLog(@"channels = %d",cn);
    
    // Append negative channels to detect ER- (bright regions over dark background)
    for (int c = 0; c < cn-1; c++)
        channels.push_back(255-channels[c]);
    
    /*Mat tmp = imread([self filePathWithFileName:@"stop.jpg"]);
     NSLog(@"empty mat %i", tmp.empty());*/
    
    // Create ERFilter objects with the 1st and 2nd stage default classifiers
    /*!RECONSIDER THE PARAMS!*/
    // default   Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1("trained_classifierNM1.xml"),16,0.00015f,0.13f,0.2f,true,0.1f);
    //    Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2("trained_classifierNM2.xml"),0.5);
    // current Best   Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1([self filePathWithFileName:
    //                                                                    @"trained_classifierNM1.xml"]),4,0.001f,0.1f,0.02f,true,0.01f);
    //    Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2([self filePathWithFileName:@"trained_classifierNM2.xml"]),0.03);
    
    Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1([self filePathWithFileName:
                                                                    @"trained_classifierNM1.xml"]),4,0.001f,0.1f,0.02f,true,0.01f);
    Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2([self filePathWithFileName:@"trained_classifierNM2.xml"]),0.03);
    
    vector<vector<ERStat> > regions(channels.size());
    // Apply the default cascade classifier to each independent channel (could be done in parallel)
    cout << "Extracting Class Specific Extremal Regions from " << (int)channels.size() << " channels ..." << endl;
    cout << "    (...) this may take a while (...)" << endl << endl;
    for (int c=0; c<(int)channels.size(); c++)
    {
        er_filter1->run(channels[c], regions[c]);
        er_filter2->run(channels[c], regions[c]);
    }
    
    // Detect character groups
    cout << "Grouping extracted ERs ... "<< endl ;
    erGrouping(channels, regions, [self filePathWithFileName:@"trained_classifier_erGrouping.xml"], 0.5, groups);
    
    cout<<"Group no = "<<groups.size()<< endl;
    
    er_filter1.release();
    er_filter2.release();
    regions.clear();
}

+(NSArray *) textGroupsSortAndMerge:(vector<cv::Rect> &)groups{
    if (!groups.empty()) {
        NSMutableArray *groupArray = [[NSMutableArray alloc]init];
        for (int i=(int)groups.size()-1; i>=0; i--){
            cout<<"("<<groups.at(i).x<<", "<<groups.at(i).y<<")"<<endl;
            
        }
        return groupArray;

    }
    else{
        cout<<"NO text groups available!"<<endl;
        return Nil;
    }
}

+(string) filePathWithFileName:(NSString *) filename{
    NSString *rspath = [NSString stringWithString:[[NSBundle mainBundle] resourcePath]];
    //NSLog(@"PATH: %@",rspath);
    NSArray *parts = [NSArray arrayWithObjects:
                      rspath, filename, (void *)nil];
    NSString *filepath = [NSString pathWithComponents:parts];
    const char *cfilepath = [filepath fileSystemRepresentation];
    string cfilepathstr(cfilepath);
    return cfilepathstr;
    
}

+(void) groupsDrawWithMat:(Mat &)src andGroups:(vector<cv::Rect> &)groups
{
    cout<<"Drawing groups..."<< endl;
    for (int i=(int)groups.size()-1; i>=0; i--){
        rectangle(src,groups.at(i).tl(),groups.at(i).br(),Scalar( 0, 255, 255 ), 3, 8 );
    }
}


@end
