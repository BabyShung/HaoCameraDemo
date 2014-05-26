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
#include <opencv2/opencv.hpp>
#include "UIImage+OpenCV.h"
#include  <opencv2/imgproc.hpp>
#include  <opencv2/objdetect.hpp>
#include  <opencv2/highgui.hpp>


using namespace cv;
using namespace std;

@implementation TextDetector
+(UIImage *)detectTextRegions:(UIImage *)orgImg{
    NSLog(@"DetectText Function called!");
    
    //Initialize original Mat for text detection
    Mat orgMat = [orgImg CVMat];
    cvtColor(orgMat, orgMat, COLOR_BGRA2BGR);
    
    //Extract channels to be processed individually
    vector<Mat> channels;
    computeNMChannels(orgMat, channels);
    int cn = (int)channels.size();
    
    NSLog(@"channels = %d",cn);
    
    // Append negative channels to detect ER- (bright regions over dark background)
    for (int c = 0; c < cn-1; c++)
        channels.push_back(255-channels[c]);
    
    /*Mat tmp = imread([self filePathWithFileName:@"stop.jpg"]);
     NSLog(@"empty mat %i", tmp.empty());*/
    
    // Create ERFilter objects with the 1st and 2nd stage default classifiers
    /*!RECONSIDER THE PARAMS!
    Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1([self filePathWithFileName:
                                                                   @"trained_classifierNM1.xml"]),4,0.00015f,0.13f,0.2f,true,0.1f);
    Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2([self filePathWithFileName:@"trained_classifierNM2.xml"]),0.5);*/
    Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1([self filePathWithFileName:
                                                                    @"trained_classifierNM1.xml"]),4,0.0001f,0.01f,0.002f,true,0.01f);
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
    cout << "Grouping extracted ERs ... ";
    vector<cv::Rect> groups;
    erGrouping(channels, regions, [self filePathWithFileName:@"trained_classifier_erGrouping.xml"], 0.5, groups);
    
    cout<<"Group no = "<<groups.size();
    
    for (int i=(int)groups.size()-1; i>=0; i--)
    {
        if (orgMat.type() == CV_8UC3)
            rectangle(orgMat,groups.at(i).tl(),groups.at(i).br(),Scalar( 0, 255, 255 ), 3, 8 );
    }
    
    UIImage *result = [UIImage imageWithCVMat:orgMat];
    
    
    // memory clean-up
    er_filter1.release();
    er_filter2.release();
    regions.clear();
    if (!groups.empty())
    {
        groups.clear();
    }
    
    return result;
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

@end
