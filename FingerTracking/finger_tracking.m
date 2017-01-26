function varargout = finger_tracking(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @finger_tracking_OpeningFcn, ...
                   'gui_OutputFcn',  @finger_tracking_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT




% --- Executes just before finger_tracking is made visible.
function finger_tracking_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = finger_tracking_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

    handles.output=hObject;
    import java.awt.Robot;                   %access to java library
    import java.awt.event.*;
    mouse = Robot;

    acik = imaqfind();  
    delete(acik);                            %To avoid to take error when worked second time

    vid = videoinput('winvideo',1,'YUY2_640x480');  

    set(vid,'framesperTrigger',1); 
    set(vid,'TriggerRepeat',Inf);
    vid.FrameGrabInterval = 2;

    vid_src = getselectedsource(vid);
    set(vid_src,'Tag','motion detection setup');

    start(vid)

        while(vid.FramesAcquired<=1000)         %Stop after 1000 frames

            frame = getdata(vid);
            I=squeeze(frame);                   

            %SEGMENTATION
            method1 = zeros(480,640);   

            mx=max(I(:));                       %max ve min values on histogram of the image
            mn=min(I(:));

            [row col band] = size(I);
            totalPix = row*col;

            thr=(mx+mn)/2;                      %threshold for B&W

                for i=1:totalPix        
                        if I(i)>=thr      
                            method1(i) = 255;
                        else
                            method1(i) = 0;
                        end
                end

       
            method1 = medfilt2(method1);                 %salt-pepper noise cleaning
            method1_uint8 = uint8(medfilt2(method1));

            A=method1_uint8;

            B=zeros(1,1);

                %9 BLOCKS CONTROL 

                for i=2:3:475
                    for j=2:3:635
                        if A(i,j)==255
                            if A(i,j-1)==255
                                if A(i-1,j-1)==255
                                    if A(i-1,j)==255
                                        if A(i-1,j+1)==255
                                            if A(i,j+1)==255
                                                 if A(i+1,j+1)==255
                                                     if A(i+1,j)==255
                                                         if A(i+1,j-1)==255

                                                             B=[B 0 i j];   % array of coordinates which have enough density

                                                         end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end





            possibleCoordinatesOfFinger=zeros(1,2);
            k=1;
            koor1=0;
            a=1;
            numberoffingers=0;
            koor2=0;   
            ara1=0;
            uc2=0;
            z=0;




                for i=koor1+3:3:numel(B)-6         %looking for coordinate which has a size of real finger size 

                    if  B(i)==B(i+3)
                        k=k+1;
                        if k>5
                            koor1=B(i)+10;
                            koor2=B(i+1)+5; 

                            for i=koor1:480
                                j=koor2;    
                                if A(i,j)==255
                                   z=z+1;
                                else
                                break
                                    if z>100
                                        break
                                    end
                                end

                            end
                        else
                        koor1=koor1+3;
                        end

                        if z>100 
                            possibleCoordinatesOfFinger(1)=koor1;
                            possibleCoordinatesOfFinger(2)=koor2;

                            possibleCoordinatesOfFinger

                        break
                        end

                    end 
                end




                % SET LABELS
                % make image smaller 

                if koor1-20<0                
                   C=zeros(koor1+100,640);   
                   for i=1:koor1+100
                       for j=1:640
                           C(i,j)=A(i,j);
                       end
                   end
                end

                if koor1+100>480        
                   C=zeros(480-koor1+21,640);
                   for i=koor1-20:480
                       for j=1:640
                       C(i-koor1+21,j)=A(i,j);
                       end
                   end
                end

                if koor1-20>0 & koor1+100<480  %set a boundry for finger positions on the image
                   C=zeros(121,640);
                   for i=koor1-20:koor1+100
                       for j=1:640
                       C(i-koor1+21,j)=A(i,j);
                       end
                   end
                end





            C= bwareaopen(C,50);     %Smaller than 50 pixels objects are deleted

            [etiket, sayi]= bwlabel(C);   %number of objects
            numberoffingers=sayi

            handles.image=A; 
            axes(handles.axes1);
            imshow(handles.image);

                if possibleCoordinatesOfFinger(1)>0 

                    konum = [possibleCoordinatesOfFinger(1) possibleCoordinatesOfFinger(2)];
                          mouse.mouseMove(((640-konum(2))/640)*1920,(konum(1)/480)*1080);

                end
                if numberoffingers==2             %right click on mouse
                      mouse.mousePress(4)     
                      mouse.mouseRelease(4)
                      pause(0.5);
                end

                if numberoffingers>2              %left click on mouse
                     mouse.mousePress(16)     
                     mouse.mouseRelease(16)
                     pause(0.5);
                end


        end
    stop(vid)
    axis off


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
