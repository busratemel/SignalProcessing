%ISTANBUL TECHNICAL UNIVERSITY
%SPEED RECOGNIZATION BY CAMERA MOUNTED ON THE CAR
%MAY, 2014


clear all; close all; clc;

centroids_old = [0 0];
V = 0;
son_frame = 0;
kf=0;

%% video reading
 vid = VideoReader('video1.2.avi');
 vidFrames = read(vid);
   
    for i=1:size(vidFrames,4)
        I=squeeze(vidFrames(:,:,:,i));   

        %%Morfology
        I2 = imcrop(I,[120 340 400 140]);        % [XMIN(column) YMIN(row) WIDTH HEIGHT]
        I3 = rgb2gray(I2);
        I4 = imextendedmax(I3,50);               % threshold=50
        %[level EM] = graythresh(I3);       	 %otsu method - graythresh algorithm
        %I4 = im2bw(I3,level);                   

        I6 = bwareaopen(I4,100);                 % ex: date part

        se = strel('line',11,90);                % nesneleri genlestiriyor, bosluklari dolduruyor.
        dilatedBW = imdilate(I6,se);  
        I7=dilatedBW; 
        [I8, n] = bwlabel(I7);                   % n:etiket sayisi 
            
            for p=1:n     
                len(p) = length(find(I8==p));    % size of labels 
            end
         %%
        [sortedLEN, idx2] = sort(len, 'descend');   
        kf=kf+1;
            
            for k=1:2                            % first two long object        
            Iobject = I8==idx2(k);               % True/False : Left just one object 

            [x, y] = find(Iobject==1);           % x. row; y. column -> coordinates of founded objects are stored in matrix of [x, y].
            [a, b]= size(find(Iobject==1));      

                 if a>1500 && a<4000             % Boundary values are determined by testing real samples of road strip lines
                                                 
                     vector_x = 1;               % Number of total pixels in the same row
                    
                     for s = [1,6,10]
                         z = x(s);     
                         for  j=1:size(x)    
                             if x(j) == z;  
                                vector_x = vector_x+1;
                             end
                         end
                         vector_x_ara(s) = vector_x;    
                     end 
                     
                     vector_x_last = (sum(vector_x_ara))/6;    
                     vector_y = max(x)-min(x);                      % Number of total pixels in the same column
                     
                     if vector_x_last>20 && vector_x_last<50        

                          if vector_y>40 && vector_y<140

                               if vector_x_last < vector_y        

                                    Imx = cat(3,150.*Iobject,-80.*Iobject,-80.*Iobject);      %Cover the object by red line NOT:others are still B&W.
                                    I2 = uint8(Imx+double(I2));                               %Combine it with the real image

                                    cx = mean(x);                                             %Finding center of the object
                                    cy = mean(y);

                                    losl = 3;                                                 %Real value of length of strip line
                                    dbst = 3;                                                 %Real value of distance between two strip lines
                                    dbcosl = losl+dbst;                                       %Real value of distance between centers of two strip lines
                                    virtual_strip_line = vector_y;
                                    guess_distance = (dbcosl*vector_y)/losl;          
                                    centroids = [cx cy]; 
                                    d = abs(centroids(2)-(centroids_old(2)+guess_distance));   
                                    centroids_old = centroids;
                                    cbg(i,:)=centroids;
                                    deltaY = d;                                               %Processed distance on the frame -pixel- 


                                    V = (deltaY * 0.36 * 4.5)/(kf*0.042 * virtual_strip_line);
                                    V = V / ( i-son_frame);
                                    K(i) = V;

                                    son_frame=i;
                                    kf=0;                  
                                    break;
                              end
                          end
                     end           
                 end     


             end
          imshow(I2);
          if V>50
         text(20,120,sprintf('Speed of the Car: %3.2f km/s',V),'BackgroundColor',[.7 .9 .7]);
        end
     drawnow;
    end







