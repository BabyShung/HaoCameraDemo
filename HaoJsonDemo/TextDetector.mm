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



using namespace cv;
using namespace std;

@implementation TextDetector

//Return a UIImage with its text regions marked
+(NSMutableArray *)detectTextRegions:(UIImage *)orgImg
{
    NSLog(@"DetectText Function called!");
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    
    //Initialize original Mat for text detection
    Mat orgMat = [orgImg CVMat8UC3];
    
    
    //Detect text groups
    vector<cv::Rect> groups, finalgroups;
    [self textRegionsOfC3Mat:orgMat withGroups:groups];
    
    if (!groups.empty())
    {
        //Sort and Merge groups
        [self sortAndMergeGroups:groups andResult:finalgroups];
        

        int gsize = finalgroups.size();
        cout<<"Crop images..."<<endl;
        
        //Crop the text regions, convert to UIImage and save in array
        for (int i = 0; i < gsize ; i++)
        {
            Mat tmpMat;
            orgMat(finalgroups.at(i)).copyTo(tmpMat);
            [imgArray addObject:[UIImage imageWithCVMat:tmpMat]];
            
            
        }
        
        //Draw the groups on the Mat
        [self groupsDrawWithMat:orgMat andGroups:finalgroups];
        
        //Convert Mat to UIImage
        UIImage *resImg = [UIImage imageWithCVMat:orgMat];
        [imgArray addObject:resImg];
        
        // Memory clean-up
        groups.clear();
        finalgroups.clear();
        
    }
    
    return imgArray;
}


//Return UIImages of text Regions AND their Locations IN ORDER
+(NSArray *)UIImagesOfTextRegions:(UIImage *)orgImg withLocations:(NSMutableArray *)locations
{
    
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    
    if(!locations)
    {
        NSException *excpt = [[NSException alloc]initWithName:
                              @"NilArray" reason:@"Array NOT init" userInfo:nil];
        @throw excpt;
    }
    
    if (locations.count > 0)
    {
        [locations removeAllObjects];
    }
        
    //Initialize original Mat for text detection
    Mat orgMat = [orgImg CVMat8UC3];
        
    //Detect text groups
    vector<cv::Rect> groups, finalgroups;
    [self textRegionsOfC3Mat:orgMat withGroups:groups];
        

    if (!groups.empty())
    {
        //Sort and Merge text groups
        [self sortAndMergeGroups:groups andResult:finalgroups];
        
        int gsize = finalgroups.size();
        cout<<"Crop images..."<<endl;
        
        for (int i = 0; i < gsize ; i++)
        {
            //Crop the text regions, convert to UIImage and save in array
            Mat tmpMat;
            orgMat(finalgroups.at(i)).copyTo(tmpMat);
            [imgArray addObject:[UIImage imageWithCVMat:tmpMat]];
            
            //Save Rects in Mutable Array
            CGRect tmpRect = CGRectMake(finalgroups.at(i).x, finalgroups.at(i).y, finalgroups.at(i).width, finalgroups.at(i).height);
            [locations addObject:[NSValue valueWithCGRect:tmpRect]];
        }
        groups.clear();
        finalgroups.clear();
    }
    return imgArray;

}

//Comparison function for std::sort
//Sort regions y-axis desc. and x-axis asce.
bool compareLoc(const cv::Rect &a,const cv::Rect &b)
{
    if (a.y < b.y) return true;
    else if (a.y == b.y)
    {
        if(a.x < b.x) return true;
        else return false;
    }
    else return false;
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
    {
        channels.push_back(255-channels[c]);
    }
    
    
    // Create ERFilter objects with the 1st and 2nd stage default classifiers
    /*!RECONSIDER THE PARAMS!
     default   Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1("trained_classifierNM1.xml"),16,0.00015f,0.13f,0.2f,true,0.1f);
        Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2("trained_classifierNM2.xml"),0.5);
     current Best
        Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1([self filePathWithFileName:
                                                                        @"trained_classifierNM1.xml"]),4,0.001f,0.1f,0.02f,true,0.01f);
        Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2([self filePathWithFileName:@"trained_classifierNM2.xml"]),0.03);*/
//    Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1([self filePathWithFileName:
//                                                                    @"trained_classifierNM1.xml"]),16,0.001f,0.2f,0.02f,true,0.01f);
//    Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2([self filePathWithFileName:@"trained_classifierNM2.xml"]),0.3);
        Ptr<ERFilter> er_filter1 = createERFilterNM1(loadClassifierNM1([self filePathWithFileName:
                                                                        @"trained_classifierNM1.xml"]),8,0.001f,0.3f,0.02f,true,0.01f);
        Ptr<ERFilter> er_filter2 = createERFilterNM2(loadClassifierNM2([self filePathWithFileName:@"trained_classifierNM2.xml"]),0.3);
    
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

//Sort and Merge text groups
+(void) sortAndMergeGroups:(vector<cv::Rect> &)groups andResult:(vector<cv::Rect> &)finalgroups
{
    if (!groups.empty())
    {
        
        int len = groups.size();
        cout<<"....Sorting groups...."<<endl;
        std::sort(groups.begin(), groups.end(), compareLoc);
        for (int i =0; i<len; i++) {
            cout<<"("<<groups.at(i).x<<", "<<groups.at(i).y<<")"<<endl;
        }
        
        cout<<"....Merging groups...."<<endl;
        finalgroups.push_back(groups.at(0));
        for (int i = 1; i < len ; i++){
            //if the current rect is not inside the previous one, save it
            if (!((finalgroups.back() & groups.at(i)) == groups.at(i))) {
                finalgroups.push_back(groups.at(i));
                
            }
        }
    }

}



+(string) filePathWithFileName:(NSString *) filename
{
    //Retrieve resource folder path
    NSString *rspath = [NSString stringWithString:[[NSBundle mainBundle] resourcePath]];
    
    //Generate file path with file name
    NSArray *parts = [NSArray arrayWithObjects:
                      rspath, filename, (void *)nil];
    NSString *filepath = [NSString pathWithComponents:parts];
    const char *cfilepath = [filepath fileSystemRepresentation];
    
    //Transform string format
    string cfilepathstr(cfilepath);
    return cfilepathstr;
    
}

+(void) groupsDrawWithMat:(Mat &)src andGroups:(vector<cv::Rect> &)groups
{
    cout<<"Drawing groups..."<< endl;
    for (int i=(int)groups.size()-1; i>=0; i--)
    {
        rectangle(src,groups.at(i).tl(),groups.at(i).br(),Scalar( 0, 255, 255 ), 3, 8 );
    }
}


@end
