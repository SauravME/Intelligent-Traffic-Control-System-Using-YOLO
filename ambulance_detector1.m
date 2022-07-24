clc
close all
clear all;
warning off;
load('Ambulance1.mat','Ambulance1')
imageSize = [224 224 3];
numClasses = 4;
anchorBoxes = [
    43 59
    18 22
    23 29
    84 109
    
];
base = resnet50;

inputlayer=base.Layers(1);

middle =base.Layers(2:174);

finallayer=base.Layers(175:end);

baseNetwork=[inputlayer
    
               middle
               
               finallayer];
           
 featureLayer = 'activation_40_relu';
  lgraph = yolov2Layers(imageSize,numClasses,anchorBoxes,base,featureLayer);

options = trainingOptions('sgdm', ...
        'MiniBatchSize',32, ....
        'InitialLearnRate',1e-3, ...
        'MaxEpochs',220);
    
vehicleDataset=Ambulance1;

 [detector,info] = trainYOLOv2ObjectDetector(vehicleDataset,lgraph,options);
the_Video=VideoReader('ambulance.mp4');
number=0;
t=1;
p=dir('*.jpg')
for i=1:length(p)
    frame=imread(p(i).name)
% inp=input('');
%  imread('image'i'.jpg'
%  frame=imread(inp);
[bbox, score, label] = detect(detector, frame, 'MiniBatchSize', 32);
object=size(label,1);
number_of_cars= size(bbox, 1);
number = number_of_cars + number;
t=number*0.5;
frame=insertText(frame, [100,100], number, 'BoxOpacity',1,'fontsize',20);
if t>=5
    %frame=insertText(frame, [90,60], t, 'BoxOpacity',1,'fontsize',20);
    frame=insertText(frame, [50,60], 'Time=', 'BoxOpacity',1,'fontsize',20);
    t=1;
    number=0;
end
    
if object >=1
     for zz=1: length(label)
    
            if label(zz)=='ambulance'
                frame=insertText(frame, [200,100], 'STOP', 'BoxOpacity',1,'fontsize',40);
                pause(5);
            end
     end
 frame = insertObjectAnnotation(frame,'rectangle',bbox,label);
end

%figure
imshow(frame)
end
the_Video=VideoReader('ambulance.mp4');
videoplayer = vision.VideoPlayer('Name' , 'detected_ambulance');
videoplayer.Position(3:4)= [650,500];
while hasFrame (the_Video)
    frame  = readFrame(the_Video);
    [bbox, score, label] = detect(detector, frame, 'MiniBatchSize', 32);
object=size(label,1);
number_of_cars= size(bbox, 1);
frame=insertText(frame, [100,100], number_of_cars, 'BoxOpacity',1,'fontsize',20);
if score>=0.65
    
    if object >=1
       for zz=1: length(label)
    
            if label(zz)=='Ambulance'
                frame=insertText(frame, [50,50], 'STOP', 'BoxOpacity',1,'fontsize',40);
                pause(1)
        
            end
       end
     frame = insertObjectAnnotation(frame,'rectangle',bbox,label);
    end
end
    step(videoplayer, frame);
end
