//
//  ImagePreProcessor.m
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ImagePreProcessor.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"

@implementation ImagePreProcessor


-(cv::Mat)toGrayMat:(UIImage *) inputImage{
    
    cv::Mat matImage = [inputImage CVGrayscaleMat];
    return matImage;
}

-(UIImage *)toGrayUIImage:(cv::Mat) inputMat{

    UIImage *img = [[UIImage alloc] init];
    img = [UIImage imageWithCVMat:inputMat];
    return img;
}


-(cv::Mat)threadholdControl:(cv::Mat) inputImage{
    
    cv::Mat output;
    cv::adaptiveThreshold(inputImage, output, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
    return output;

}

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w{
    
    cv::Mat output;
    cv::Size size;
	size.height = h;
	size.width = w;
    cv::GaussianBlur(inputImage, output, size, 0.8);
    return output;

}

-(cv::Mat)laplacian:(cv::Mat)inputImage{
    
    cv::Mat output;
    cv::Mat kernel = (cv::Mat_<float>(3, 3) << 0, -1, 0, -1, 5, -1, 0, -1, 0); //Laplacian operator
    cv::filter2D(inputImage, output, output.depth(), kernel);
    return output;

}

-(cv::Mat)removeBackgroud:(cv::Mat)inputImage{
    
    cv::Size size;
	size.height = 3;
	size.width = 3;
    inputImage = [self laplacian:inputImage];
    cv::GaussianBlur(inputImage, inputImage, size, 0.8);
	cv::adaptiveThreshold(inputImage, inputImage, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
	cv::GaussianBlur(inputImage, inputImage, size, 0.8);
    inputImage = [self laplacian:inputImage];
    return inputImage;
}




-(cv::Mat)processImage: (cv::Mat)inputImage{
    // this function check the input image's style : black+white or white+black
    cv::Mat output;
    int isBlackBack = [self checkBackground:inputImage];
    if (isBlackBack == 1) {
        output = [self laplacian:inputImage];
        NSLog(@"IS black back ground\n");
    }
    else{
        output = [self removeBackgroud:inputImage];
        NSLog(@"IS White back ground\n");
        
    }
    
    return output;
}


-(int)checkBackground:(cv::Mat )input //Fang's
{
    int rows = input.rows;
    int cols = input.cols;
    
    //count the sum of the pixl
    int sum_pixl = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            uchar pixl = input.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            sum_pixl = sum_pixl + pixl_int;
        }
    }
    //count the average of the pixel
    int ave_pixl = sum_pixl/(rows*cols);
    //count_white the nuber of pixl whose value is bigger than average
    int count_white = 0;
    //count_white the nuber of pixl whose value is smaller than average
    int count_black = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            
            uchar pixl = input.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            if (pixl_int>=ave_pixl) {
                count_white= count_white+1;
            }else{
                count_black = count_black +1;
            }
            
        }
    }
    //if more white then Black background（0） others （1）
    if (count_black <= count_white) {
        return 0;
    } else {
        return 1;
    }
    
}






//========================================= Fang
-(cv::Mat)canny:(cv::Mat)input{
    cv::Mat output;
    cv::Canny(input, output, 0.8,0.5);
    return output;
}

-(cv::Mat)bilateralFilter:(cv::Mat)input
{
    cv::Mat output;
    cv::bilateralFilter (input, output, 15, 80, 80 );
    return output;
    
}

-(cv::Mat)boxFilter:(cv::Mat)input
{
    cv::Mat output;
    cv::Size size;
	size.height = 3;
	size.width = 3;
    cv::boxFilter(input, output, CV_16S, size);
    return output;
}

-(cv::Mat)erode:(cv::Mat)input
{
    int erosion_size = 60;
    cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS,
                                                cv::Size(2 * erosion_size + 1, 2 * erosion_size + 1),
                                                cv::Point(erosion_size, erosion_size) );
    cv::Mat output;
    cv::erode (input, output, element);
    return output;
    
}

-(cv::Mat)dilate:(cv::Mat)input
{
    int erosion_size = 60;
    cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS,
                                                cv::Size(2 * erosion_size + 1, 2 * erosion_size + 1),
                                                cv::Point(erosion_size, erosion_size) );
    cv::Mat output;
    cv::dilate (input, output, element);
    return output;
    
}

-(cv::Mat)laplacian2:(cv::Mat)input
{
    cv::Mat output;
    cv::Laplacian(input, output, CV_16S);
    return output;
}


//==========================================/Fang



//========================================ANPR

//-----

- (cv::Mat)processImage_ARPN:(cv::Mat)src
{
    cv::Mat source = src;
    cv::Mat output = [self filterMedianSmoot:source];
    
    //threshold(output, output, 230, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    //threshold( output, output, 150, 255, CV_THRESH_BINARY );
    //GaussianBlur(output, output, cv::Size(5, 5), 0, 0);
    //adaptiveThreshold(output, output, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, 75, 10);
    
    /* Pre-processing */
    
    cv::Mat img_gray;
    cv::cvtColor(source, img_gray, CV_BGR2GRAY);
    blur(img_gray, img_gray, cv::Size(5,5));
    //medianBlur(img_gray, img_gray, 9);
    cv::Mat img_sobel;
    cv::Sobel(img_gray, img_sobel, CV_8U, 1, 0, 3, 1, 0, cv::BORDER_DEFAULT);
    cv::Mat img_threshold;
    threshold(img_gray, img_threshold, 0, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    cv::Mat element = getStructuringElement(cv::MORPH_RECT, cv::Size(3, 3) );
    morphologyEx(img_threshold, img_threshold, CV_MOP_CLOSE, element);
    
    /* Search for contours */
    
    std::vector<std::vector<cv::Point> > contours;
    cv::Mat contourOutput = img_threshold.clone();
    cv::findContours( contourOutput, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE );
    
    std::vector<cv::Vec4i> hierarchy;
    
    /* Get the largest contour (Possible license plate) */
    
    int largestArea = -1;
    std::vector<std::vector<cv::Point> > largestContour;
    
    std::vector<std::vector<cv::Point> > polyContours( contours.size() );
    
    //std::vector<cv::Point> approx;
    for( int i = 0; i < contours.size(); i++ ){
        approxPolyDP( cv::Mat(contours[i]), polyContours[i], arcLength(cv::Mat(contours[i]), true)*0.02, true );
        
        if (polyContours[i].size() == 4 && fabs(contourArea(cv::Mat(polyContours[i]))) > 1000 && isContourConvex(cv::Mat(polyContours[i]))){
            double maxCosine = 0;
            
            for (int j = 2; j < 5; j++){
                double cosine = fabs(angle(polyContours[i][j%4], polyContours[i][j-2], polyContours[i][j-1]));
                
                maxCosine = MAX(maxCosine, cosine);
            }
            
            if (maxCosine < 0.3)
                NSLog(@"Square detected");
        }
        
    }
    
    for( int i = 0; i< polyContours.size(); i++ ){
        
        int area = fabs(contourArea(polyContours[i],false));
        if(area > largestArea){
            largestArea = area;
            largestContour.clear();
            largestContour.push_back(polyContours[i]);
        }
        
    }
    
    // Contour drawing debug
    cv::Mat drawing = cv::Mat::zeros( contourOutput.size(), CV_8UC3 );
    if(largestContour.size()>=1){
        
        cv::drawContours(source, largestContour, -1, cv::Scalar(0, 255, 0), 0);
        
    }
    
    /* Get RotatedRect for the largest contour */
    
    std::vector<cv::RotatedRect> minRect( largestContour.size() );
    for( int i = 0; i < largestContour.size(); i++ )
        minRect[i] = minAreaRect( cv::Mat(largestContour[i]) );
    
    cv::Mat drawing2 = cv::Mat::zeros( img_threshold.size(), CV_8UC3 );
    for( int i = 0; i< largestContour.size(); i++ ){
        
        cv::Point2f rect_points[4]; minRect[i].points( rect_points );
        for( int j = 0; j < 4; j++ ){
            line( drawing2, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,255,0), 1, 8 );
            
        }
        
    }
    
    //Get Region Of Interest ROI
    
    cv::RotatedRect box = minAreaRect( cv::Mat(largestContour[0]));
    cv::Rect box2 = cv::RotatedRect(box.center, box.size, box.angle).boundingRect();
    
    box2.x += box2.width * 0.028;
    box2.width -= box2.width * 0.05;
    box2.y += box2.height * 0.25;
    box2.height -= box2.height * 0.55;
    
    cv::Mat cvMat = img_threshold(box2).clone();
    
    //UIImage *filtered=[UIImage imageWithCVMat:cvMat];
    return cvMat;
}



double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 )
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1 * dx2 + dy1 * dy2)/sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}

//-----




-(cv::Mat)filterMedianSmoot:(cv::Mat)source{

    cv::Mat results;
    cv::medianBlur(source, results, 3);
    return results;

}

-(cv::Mat) filterGaussian:(cv::Mat)source{
    
    cv::Mat results;
    cv::GaussianBlur(source, results, cvSize(3, 3), 0);
    return results;
}


-(cv::Mat)equalize:(cv::Mat)source{

    cv::Mat results;
    cv::equalizeHist(source, results);
    return results;
}


-(cv::Mat) binarize:(cv::Mat)source{

    cv::Mat results;
    int blockDim = MIN( source.size().height / 4, source.size().width / 4);
    if(blockDim % 2 != 1) blockDim++;
    cv::adaptiveThreshold(source, results, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, blockDim, 0);
    return results;

}




-(int) correctRotation: (cv::Mat) image :(cv::Mat) output :(float) height{

    float prop = 0;
	prop = height / image.cols;
	int cols = image.cols * prop;
	int rows = image.rows * prop;
    
	std::vector<cv::Vec4i> lines;
	cv::Mat resized(cols, rows, CV_8UC1, 0);
	cv::Mat dst(cols, rows, CV_8UC1, 255);
	cv::Mat original = image.clone();
	cv::Mat kernel(1, 2, CV_8UC1, 0);
	cv::Mat kernel2(3, 3, CV_8UC1, 0);
	
	cv::Size si(0, 0);
    
	cv::threshold(image, image, 100, 255, CV_THRESH_BINARY);
	cv::morphologyEx(image, image, cv::MORPH_OPEN, kernel2, cv::Point(1, 1), 15);
	cv::Canny(image, image, 0, 100);
	cv::HoughLinesP(image, lines, 1, CV_PI / 180, 80, 30, 10 );
    
	double ang = 0;
    
	cuadrante c[4];
	for (int i = 0; i < 4; i++){
		c[i].media = 0;
		c[i].contador = 0;
	}
	for( size_t i = 0; i < lines.size(); i++ ){
		cv::Vec4i l = lines[i];
		cv::line( dst, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(0, 0, 0), 3, CV_AA);
		ang = atan2(l[1] - l[3], l[0] - l[2]);
		if (ang >= 0 && ang <= CV_PI / 3){
			c[0].media += ang;
			c[0].contador++;
		} else if (ang >(2 * CV_PI) / 3 && ang <= CV_PI){
			c[1].media += ang;
			c[1].contador++;
		} else if (ang > -1 * CV_PI && ang < -2 * CV_PI / 3){
			c[2].media += ang;
			c[2].contador++;
		} else if (ang > CV_PI / 3 && ang < 0){
			c[3].media += ang;
			c[3].contador++;
		}
	}
	int biggest = 0;
	int bi = 0;
	double rot = 0;
	double aux;
    
	for (int i =0; i < 4;i++)
		if (c[i].contador > bi){
			biggest = i;
			bi = c[i].contador;
		}
    
	aux = (180 * (c[biggest].media / c[biggest].contador) / CV_PI);
	aux = (aux < 0) ? -1 * aux : aux;
	if (biggest == 1 || biggest == 2){
        rot = 180 - aux;
	} else {
		rot = aux;
	}
	
	if (!(biggest == 0 || biggest == 2)){
		rot = rot * -1;
	}
    
	if (rot<-3 || rot > 3){
		image = [self rotateImage: original :rot];
	} else {
		image = original;
	}
	output = image.clone();
	return 0;
}


-(cv::Mat) rotateImage:(cv::Mat) source :(double) angle{

    cv::Point2f src_center(source.cols / 2.0F, source.rows / 2.0F);
    cv::Mat rot_mat = cv::getRotationMatrix2D(src_center, angle, 1.0);
    cv::Mat dst;
    cv::warpAffine(source, dst, rot_mat, source.size());
    return dst;

}





//========================================/ANPR


//========================================Wiener filter


-(UIImage *)deBlur:(UIImage *)inputimage{
    
    //use Wiener filter
    /*=============================================== implement Wiener Filter==============================================================*/
    
    
    IplImage *img= [self CreateIplImageFromUIImage:inputimage];//原始图图像1
    //得到灰度化图像g1
    IplImage*g=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_8U,1);
    cvCvtColor(img,g,CV_RGB2GRAY);
    
    IplImage*gg=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//输入用于计算的图像
    cvConvertScale(g,gg);
    
    IplImage*localMean=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//“均值”具体解释见程序代码求解公式
    IplImage*localVar=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//“方差”
    IplImage*f=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_32F,1);//输出用于计算的图像
    
    /*得到滤波模板*/
    CvMat*mat=cvCreateMat(5,5,CV_32FC1);
    cvZero(mat);
    int row,col;
    for(row=0;row<mat->height;row++)
    {
        float*pData=(float*)(mat->data.ptr+row*mat->step);//获取第row行的行首指针，因为数据类型为浮点型，因此，通过data.ptr与step获得的字节指针需要转换为float*这样的指针
        for(col=0;col<mat->width;col++)
        {
            *pData=1;
            pData++;//因为,指针后移一位，也即是指向下一个浮点数
        }
    }
    float prod=25;//滤波模板的数值和
    float sumlocalVar=0;//方差和
    
    /*得到原始图像与模板卷积后的图像*/
    IplImage*dst=cvCreateImage(cvGetSize(g),IPL_DEPTH_32F,1);
    cvFilter2D(g,dst,mat,cvPoint(-1,-1));
    
    /*得到原始图像像素平方与模板卷积后的图像*/
    IplImage*grayImg32F2X=cvCreateImage(cvGetSize(g),IPL_DEPTH_32F,1);
    cvMul(gg,gg,grayImg32F2X);
    
    IplImage*dst2=cvCreateImage(cvGetSize(grayImg32F2X),IPL_DEPTH_32F,1);
    cvFilter2D(grayImg32F2X,dst2,mat,cvPoint(-1,-1));
    
    for(int i=0;i<(g->height);i++)
    {
        //r、p是指向图像数据首地址的指针，类型是无符号字符型
        float*r=(float*)(dst->imageData+i*dst->widthStep);
        float*p=(float*)(localMean->imageData+i*localMean->widthStep);
        float*q=(float*)(dst2->imageData+i*dst2->widthStep);
        float*m=(float*)(localVar->imageData+i*localVar->widthStep);
        float*n=(float*)(f->imageData+i*f->widthStep);
        float*o=(float*)(gg->imageData+i*gg->widthStep);
        for(int j=0;j<(g->width);j++)
        {
            p[j]=r[j]/prod;//为localMean像素赋值wrong;
            m[j]=q[j]/prod-p[j]*p[j];//为localVar像素赋值
            n[j]=o[j]-p[j];//实现公式f=g-localMean;
        }
    }
    
    
    float noise=0;
    int count=0;
    for(int i=0;i<(g->height);i++)
    {
        //r、p是指向图像数据首地址的指针，类型是无符号字符型
        float*m=(float*)(localVar->imageData+i*localVar->widthStep);
        for(int j=0;j<(g->width);j++)
        {
            noise=noise+m[j];
            count++;
        }
    }
    noise=noise/count;//求得噪声isdifferetfromMatlabvalue
    
    for(int i=0;i<(localVar->height);i++)
    {
        float*o=(float*)(gg->imageData+i*gg->widthStep);
        float*m=(float*)(localVar->imageData+i*localVar->widthStep);
        for(int j=0;j<(localVar->width);j++)
        {
            o[j]=m[j]-noise;//实现公式g=localVar-noise;误差很大，不应该！
        }
    }
    
    cvMaxS(gg,0,gg);//gg与0比，去较大值存入gg
    cvMaxS(localVar,noise,localVar);//localVar与noise比，去较大值存入localVar
    cvDiv(f,localVar,f);//f=f-localVa
    cvMul(f,gg,f);//f=f*gg
    cvAdd(f,localMean,f);//f=f+localMean
    
    IplImage*ff=cvCreateImage(cvSize(img->width,img->height),IPL_DEPTH_8U,1);//滤波后图像
    
    
    
    cvConvertScale(f,ff);
    
    
    
    
    /*======================================================== End of implementation ====================================================*/
    
    // make a new UIImage to return
    UIImage *resultUIImage = [self UIImageFromIplImage: ff];
    
    cvReleaseImage(&f);
    cvReleaseImage(&ff);
    cvReleaseImage(&img);
    cvReleaseImage(&localMean);
    cvReleaseImage(&localVar);
    cvReleaseImage(&g);
    cvReleaseMat(&mat);
    cvReleaseImage(&dst);
    cvReleaseImage(&grayImg32F2X);
    cvReleaseImage(&dst2);
    cvReleaseImage(&dst2);
    
    return resultUIImage;
    
}


- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    CGImageRef      imageRef;
    CGColorSpaceRef colorSpaceRef;
    CGContextRef    context;
    IplImage      * iplImage;
    IplImage      * returnImage;
    
    imageRef      = image.CGImage;
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    iplImage      = cvCreateImage( cvSize( image.size.width, image.size.height ), IPL_DEPTH_8U, 4 );
    context       = CGBitmapContextCreate
    (
     iplImage->imageData,
     iplImage->width,
     iplImage->height,
     iplImage->depth,
     iplImage->widthStep,
     colorSpaceRef,
     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault
     );
    
    CGContextDrawImage( context, CGRectMake( 0, 0, image.size.width, image.size.height ), imageRef );
    CGContextRelease( context );
    CGColorSpaceRelease( colorSpaceRef );
    
    returnImage = cvCreateImage( cvGetSize( iplImage ), IPL_DEPTH_8U, 3 );
    
    cvCvtColor( iplImage, returnImage, CV_RGBA2BGR);
    cvReleaseImage( &iplImage );
    
    return returnImage;
}

- (UIImage*)UIImageFromIplImage:(IplImage*)image {
    CGColorSpaceRef colorSpace;
    if (image->nChannels == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
	else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cvCvtColor(image, image, CV_BGR2RGB);
    }
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}


@end
