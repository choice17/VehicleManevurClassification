%--------------------------------------------------------------------------
% Labeling
%     function labeling generate a GUI interface for user to mannually 
%        label the video data
% 
%     Function Signatures:
%       function varargout = Labeling(varargin)
%        @input:z`
%           
%        @output:
%            
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% @author: Ruirui Liu
% @email: ruiruil@umich.edu
% @date: May.21.2017
% @copyright: Intelligent System Laboratory University of Michigan-Dearborn
%--------------------------------------------------------------------------

function varargout = Labeling(varargin)
% LABELING MATLAB code for Labeling.fig
%      LABELING, by itself, creates a new LABELING or raises the existing
%      singleton*.
%
%      H = LABELING returns the handle to a ne  w LABELING or the handle to
%      the existing singleton*.
%
%      LABELING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELING.M with the given input arguments.
%
%      LABELING('Property','Value',...) creates a new LABELING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Labeling_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Labeling_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Labeling

% Last Modified by GUIDE v2.5 03-Jan-2018 00:17:12
% Last Modified by Choi v2.5.1 26-May-2017 
%       1. labeling position is now matching with video resolution
% Last Modified by Choi v3 9-Nov-2017 tcyu@umich.edu
%       1. Enable ActiveXControl 
%       2. re-allocate the GUI 
%       3. video saving function is temp close
% Last Modified by Choi v3.11 31-Dec-2017 tcyu@umich.edu
%       1. Add write button - allow to update the table after manually
%       write on the table
%       2. fix bug on incorrectly fill up end time beginning
%       3. fill up end time during exporting table 

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Labeling_OpeningFcn, ...
    'gui_OutputFcn',  @Labeling_OutputFcn, ...
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


% --- Executes just before Labeling is made visible.
function Labeling_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Labeling (see VARARGIN)

% Choose default command line output for Labeling
handles.output = hObject;
%movegui('center') ;
movegui([200 100]);

% Update handles structure
%guidata(hObject, handles);


%global pause_flag
%global video_speed
global traffic road_status condition_row_traffic condition_row_road
global if_traffic_light if_stop if_yield if_intersection
global if_LCL if_LCR if_turn_l if_turn_r if_merge_l if_merge_r

% initial variables
%pause_flag = 0;
%video_speed = 1;
traffic=0;
road_status=0;
condition_row_traffic=0;
condition_row_road=0;
if_traffic_light=0; if_stop=0; if_yield=0; if_intersection=0;
if_LCL=0; if_LCR=0; if_turn_l=0; if_turn_r=0; if_merge_l=0; if_merge_r=0;


% UIWAIT makes Labeling wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Labeling_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
try
    varargout{1} = handles.output;
end


% --- Executes on button press in Back.
function Back_Callback(hObject, eventdata, handles)
% hObject    handle to Back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global row_num label
row_num=row_num-1;
if row_num>=2
    label=label(1:row_num-1,:);
end
set(handles.table,'Data', label);
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue(row_num);
%guidata(hObject, handles);


% --- Executes on button press in Pause.
function Pause_Callback(hObject, eventdata, handles)
% hObject    handle to Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vidObj;

if ~isempty(regexp(vidObj.status,'Playing','ONCE'))                  
    vidObj.controls.pause;
    set(hObject,'BackgroundColor',[1,0.5,0.5],'String','Play');
elseif ~isempty(regexp(vidObj.status,'Paused','ONCE'))   
    vidObj.controls.play;
     set(hObject,'BackgroundColor',[0.5,1,0.5],'String','Pause');     
elseif ~isempty(regexp(vidObj.status,'Stopped','ONCE'))       
    vidObj.controls.play;
     set(hObject,'BackgroundColor',[0.5,1,0.5],'String','Pause');
elseif ~isempty(regexp(vidObj.status,'Ready','ONCE')) 
     vidObj.controls.play;     
     set(hObject,'BackgroundColor',[0.5,1,0.5],'String','Pause');
end

%% Dynamic situations
% --- Executes on button press in lane_chang_l.
function lane_chang_l_Callback(hObject, eventdata, handles)
% hObject    handle to lane_chang_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj 
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_LCL LCL_row
if if_LCL==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,8}=1;
    LCL_row=row_num;
    if_LCL=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
else
    if_LCL=0;
    label{LCL_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue(9999);
%%guidata(hObject, handles);


% --- Executes on button press in lane_change_r.
function lane_change_r_Callback(hObject, eventdata, handles)
% hObject    handle to lane_change_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_LCR LCR_row
if if_LCR==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,9}=1;
    LCR_row=row_num;
    if_LCR=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_LCR=0;
    label{LCR_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

% --- Executes on button press in turn_l.
function turn_l_Callback(hObject, eventdata, handles)
% hObject    handle to turn_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
global if_turn_l turn_l_row
tShow = sec2timeStr(vidObj.controls.currentPosition);
if if_turn_l==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,10}=1;
    turn_l_row=row_num;
    if_turn_l=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_turn_l=0;
    label{turn_l_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);
% --- Executes on button press in turn_r.
function turn_r_Callback(hObject, eventdata, handles)
% hObject    handle to turn_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_turn_r turn_r_row
if if_turn_r==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,11}=1;
    turn_r_row=row_num;
    if_turn_r=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_turn_r=0;
    label{turn_r_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

% --- Executes on button press in merge_l.
function merge_l_Callback(hObject, eventdata, handles)
% hObject    handle to merge_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_merge_l merge_l_row
if if_merge_l==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,12}=1;
    merge_l_row=row_num;
    if_merge_l=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_merge_l=0;
    label{merge_l_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

% --- Executes on button press in merge_r.
function merge_r_Callback(hObject, eventdata, handles)
% hObject    handle to merge_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_merge_r merge_r_row
if if_merge_r==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,13}=1;
    merge_r_row=row_num;
    if_merge_r=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_merge_r=0;
    label{merge_r_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

%% Static situations
% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_stop stop_row
if if_stop==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,5}=1;
    stop_row=row_num;
    if_stop=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_stop=0;
    label{stop_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

% --- Executes on button press in Yield.
function Yield_Callback(hObject, eventdata, handles)
% hObject    handle to Yield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_yield yield_row
if if_yield==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,6}=1;
    yield_row=row_num;
    if_yield=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_yield=0;
    label{yield_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

% --- Executes on button press in traffic_light.
function traffic_light_Callback(hObject, eventdata, handles)
% hObject    handle to traffic_light (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col  vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_traffic_light traffic_light_row
if if_traffic_light==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,7}=1;
    traffic_light_row=row_num;
    if_traffic_light=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_traffic_light=0;
    label{traffic_light_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

% --- Executes on button press in Intersection.
function Intersection_Callback(hObject, eventdata, handles)
% hObject    handle to Intersection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label row_num traffic road_status headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global if_intersection intersection_row
if if_intersection==0
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}=traffic;
    
    label{row_num,14}=1;
    intersection_row=row_num;
    if_intersection=1;
    row_num=row_num+1;
    
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[1,1,1]);
    
    
else
    if_intersection=0;
    label{intersection_row,2}=tShow;
    set(handles.table,'Data',label);
    set(hObject,'BackgroundColor',[0.9,0.9,0.9]);
end
jh = findjobj(handles.table);
jhScroll = jh.getVerticalScrollBar;
jhScroll.setValue( 9999);
%guidata(hObject, handles);

%% Traffic
% --- Executes on button press in high_traffic.
function high_traffic_Callback(hObject, eventdata, handles)
% hObject    handle to high_traffic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global row_num label  headline_col vidObj
tShow = sec2timeStr(vidObj.controls.currentPosition);
global traffic condition_row_traffic road_status

if  ~strcmp(traffic,'high')
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}='high';
    
    traffic='high';
    if condition_row_traffic
        label{condition_row_traffic,2}=tShow;
    end
    condition_row_traffic=row_num;
    row_num=row_num+1;
    
    set(handles.table,'Data', label);
    set(handles.low_traffic,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.high_traffic,'BackgroundColor',[0,0.9,0.6]);
    
    jh = findjobj(handles.table);
    jhScroll = jh.getVerticalScrollBar;
    jhScroll.setValue( 9999);
    %guidata(hObject, handles);
end


% --- Executes on button press in low_traffic.
function low_traffic_Callback(hObject, eventdata, handles)
% hObject    handle to low_traffic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global row_num label  headline_col vidObj
global traffic condition_row_traffic road_status
tShow = sec2timeStr(vidObj.controls.currentPosition);
if  ~strcmp(traffic,'low')
    for column=3:headline_col
        label{row_num,column}=0;
    end    
    label{row_num,1}=tShow;
    label{row_num,3}=road_status;
    label{row_num,4}='low';
    
    traffic='low';
    if condition_row_traffic 
        label{condition_row_traffic,2}=tShow;
    end
    condition_row_traffic=row_num;
    row_num=row_num+1;
    
    set(handles.table,'Data', label);
    set(handles.low_traffic,'BackgroundColor',[0,0.9,0.6]);
    set(handles.high_traffic,'BackgroundColor',[0.9,0.9,0.9]);
    
    jh = findjobj(handles.table);
    jhScroll = jh.getVerticalScrollBar;
    jhScroll.setValue( 9999);
    %guidata(hObject, handles);
end


%% Road Status
% --- Executes on button press in parking_lot.
function parking_lot_Callback(hObject, eventdata, handles)
% hObject    handle to parking_lot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global row_num label  headline_col vidObj
global condition_row_road road_status traffic
tShow = sec2timeStr(vidObj.controls.currentPosition);
if ~strcmp(road_status,'parking_lot')
    for column=3:headline_col
        label{row_num,column}=0;
    end
 
    label{row_num,1}=tShow;
    label{row_num,3}='parking_lot';
    label{row_num,4}=traffic;
    
    road_status='parking_lot';
    
    if condition_row_road
        label{condition_row_road,2}=tShow;
    end
    condition_row_road=row_num;
    row_num=row_num+1;
    
    set(handles.table,'Data', label);
    set(handles.parking_lot,'BackgroundColor',[0,0.7,0.7]);
    set(handles.Local,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Ramp,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Highway,'BackgroundColor',[0.9,0.9,0.9]);
    
    jh = findjobj(handles.table);
    jhScroll = jh.getVerticalScrollBar;
    jhScroll.setValue( 9999);
    %guidata(hObject, handles);
end


% --- Executes on button press in Local.
function Local_Callback(hObject, eventdata, handles)
% hObject    handle to Local (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global row_num label  headline_col vidObj
global condition_row_road road_status traffic
tShow = sec2timeStr(vidObj.controls.currentPosition);
if ~strcmp(road_status,'local')
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}='local';
    label{row_num,4}=traffic;
    
    road_status='local';
    
    if condition_row_road
        label{condition_row_road,2}=tShow;
    end
    condition_row_road=row_num;
    row_num=row_num+1;
    
    set(handles.table,'Data', label);
    set(handles.parking_lot,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Local,'BackgroundColor',[0,0.7,0.7]);
    set(handles.Ramp,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Highway,'BackgroundColor',[0.9,0.9,0.9]);
    jh = findjobj(handles.table);
    jhScroll = jh.getVerticalScrollBar;
    jhScroll.setValue( 9999);
    %guidata(hObject, handles);
end


% --- Executes on button press in Ramp.
function Ramp_Callback(hObject, eventdata, handles)
% hObject    handle to Ramp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global row_num label  headline_col vidObj
global condition_row_road road_status traffic
tShow = sec2timeStr(vidObj.controls.currentPosition);
if ~strcmp(road_status,'ramp')
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}='ramp';
    label{row_num,4}=traffic;
    
    road_status='ramp';
    
    if condition_row_road
        label{condition_row_road,2}=tShow;
    end
    condition_row_road=row_num;
    row_num=row_num+1;
    
    set(handles.table,'Data', label);
    set(handles.parking_lot,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Local,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Ramp,'BackgroundColor',[0,0.7,0.7]);
    set(handles.Highway,'BackgroundColor',[0.9,0.9,0.9]);
    
    jh = findjobj(handles.table);
    jhScroll = jh.getVerticalScrollBar;
    jhScroll.setValue( 9999);
    %guidata(hObject, handles);
end

% --- Executes on button press in Highway.
function Highway_Callback(hObject, eventdata, handles)
% hObject    handle to Highway (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global row_num label  headline_col vidObj
global condition_row_road road_status traffic
tShow = sec2timeStr(vidObj.controls.currentPosition);
if ~strcmp(road_status,'highway')
    for column=3:headline_col
        label{row_num,column}=0;
    end
    label{row_num,1}=tShow;
    label{row_num,3}='highway';
    label{row_num,4}=traffic;
    
    road_status='highway';
    if condition_row_road
        label{condition_row_road,2}=tShow;
    end
    condition_row_road=row_num;
    row_num=row_num+1;
    
    set(handles.table,'Data', label);
    set(handles.parking_lot,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Local,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Ramp,'BackgroundColor',[0.9,0.9,0.9]);
    set(handles.Highway,'BackgroundColor',[0,0.7,0.7]);
    
    jh = findjobj(handles.table);
    jhScroll = jh.getVerticalScrollBar;
    jhScroll.setValue( 9999);
    %guidata(hObject, handles);
end


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label
global row_num          %row number
global video_speed
global vidObj
global headline_col
global road_status traffic
global if_traffic_light if_stop if_yield if_intersection
global if_LCL if_LCR if_turn_l if_turn_r if_merge_l if_merge_r


set(handles.Pause,'BackgroundColor',[0,0.8,0]);

headline = {'Start Time', 'End Time', 'Road Status', 'Traffic', ...
    'Stop', 'Yield', 'Traffic Light', 'Lane Change Left', ...
    'Lane Change Right', 'Turn Left', 'Turn Right',...
    'Merge Left', 'Merge Right', 'Intersection'};

headline_col=length(headline);
label = [];
for n = 1:headline_col
    label{1,n} = headline{n};
end
row_num = 2;
video_speed = 1;

% open video file
[fileName,pathName] = uigetfile('*','choose a video');
if isequal(fileName,0) || isequal(pathName,0)
    disp('User pressed cancel')
    return;
else
    disp(['User selected ', fullfile(pathName, fileName)])
end

vidObj = handles.activex4;

newvideo=vidObj.newMedia([pathName fileName]);
vidObj.currentPlaylist.appendItem(newvideo);
vidObj.settings.mute = 1;


% --- Executes during object creation, after setting all properties.
function time_show_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Save_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global label condition_row_traffic condition_row_road;
global if_traffic_light if_stop if_yield if_intersection;
global if_LCL if_LCR if_turn_l if_turn_r if_merge_l if_merge_r;
global traffic_light_row stop_row yield_row intersection_row ;
global LCR_row LCL_row turn_l_row turn_r_row merge_l_row merge_r_row
global vidObj;


[fileName,filePath] = uiputfile('*.*');

% fillup end time
endTime = sec2timeStr(vidObj.currentMedia.duration);
dynamic_states = {'traffic_light','stop','yield','intersection', ...
    'LCL','LCR','turn_l','turn_r','merge_l','merge_r'};
for dynamic_state = dynamic_states
    dynamic_state = cell2mat(dynamic_state);
    if eval(['if_' dynamic_state])
        label{eval([dynamic_state '_row']),2} = endTime;
    end
end

if condition_row_traffic
    label{condition_row_traffic,2} = endTime;
end

if condition_row_road
    label{condition_row_road,2} = endTime;
end
set(handles.table,'Data', label);

Path=strcat(filePath,fileName,'.xls');
xlswrite(Path,label);
Path=strcat(filePath,fileName,'.csv');
cell2csv(Path, label);

save([filePath fileName '.mat'],'label');

close(vidObj);
close(writeObj);


% --------------------------------------------------------------------


% --- Executes on button press in Backward.
function Backward_Callback(hObject, eventdata, handles)
% hObject    handle to Backward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vidObj;
vidObj.controls.currentPosition = vidObj.controls.currentPosition-1; 


% --- Executes on button press in Speed.
function Speed_Callback(hObject, eventdata, handles)
% hObject    handle to Speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global video_speed vidObj
video_speed = mod(video_speed,4)+1;
vidObj.settings.rate = 1+(video_speed)*0.25;
set(handles.Speed,'string',['Speed ' num2str(video_speed) 'x']);

% --- Executes on button press in Forward.
function Forward_Callback(hObject, eventdata, handles)
% hObject    handle to Forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vidObj;
vidObj.controls.currentPosition = vidObj.controls.currentPosition+3; 


% --------------------------------------------------------------------
function outime = sec2timeStr(val)
timeM = floor(val/60);
timeS = floor(val - timeM*60);
outime = [num2str(timeM,'%02i') ':' num2str(timeS,'%02i') '.' ...
num2str(floor(mod(val,1)*1000),'%03i')];


% --------------------------------------------------------------------
function save_videoLabel_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_videoLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName,filePath] = uiputfile('*.*');
load([filePath fileName]);

set(handles.table,'Data',label);
 jh = findjobj(handles.table);
    jhScroll = jh.getVerticalScrollBar;
    jhScroll.setValue( 9999);
% 
% global if_traffic_light if_yield  if_stop if_intersection if_LCR if_LCL ...
%        if_turn_l if_turn_r if_merge_l if_merge_r;
%    disp('currently not support save labeling video');
%    return;
%    
% fileName = vidObj.currentMedia.get.sourceURL;
% videObj = VideoReader(fileName);
% writerObj=VideoWriter([vidObj.currentMedia.get.name,'_done.avi']);
% open(writerObj); 
% disp('start saving label video...');
% while hasFrame(videObj)
%     
%     thisFrame = readFrame(videObj);
%     
%     % write labeled video
%     label_position = floor([50 100 150 200 250 300 350 400 450].*(videObj.Height/1080));
%     position = [ones(9,1) label_position'];
%     %position=[1 50;1 100;1 150;1 200;1 250;1 300;1 350;1 400;1 450];
%     value={['road status: ' num2str(road_status)]; ['traffic: ' num2str(traffic)]; ...
%         ['if_traffic_light: ' num2str(if_traffic_light)]; ...
%         ['if_stop: ' num2str(if_stop)]; ['if_yield:' num2str(if_yield)]; ...
%         ['if_intersection: ' num2str(if_intersection)]};
%     if if_LCL
%         value{7}=['if_lane_change: LaneChangeLeft'];
%     else
%         if if_LCR
%             value{7}=['if_lane_change: LaneChangeRight'];
%         else
%             value{7}=['if_lane_change: noLaneChange'];
%         end
%     end
%     
%     if if_turn_l
%         value{8}=['if_turn: TurnLeft'];
%     else
%         if if_turn_r
%             value{8}=['if_turn: TurnRight'];
%         else
%             value{8}=['if_turn: noTurn'];
%         end
%     end
%         
%     if if_merge_l
%         value{9}=['if_merge_lane: MergeLeft'];
%     else
%         if if_merge_r
%             value{9}=['if_merge_lane: MergeRight'];
%         else
%             value{9}=['if_merge_lane: noLaneMerge'];
%         end
%     end
%     mod_thisFrame = insertText(thisFrame, position, value, ...
%         'Font', 'Microsoft JhengHei UI', 'FontSize', floor(20*(videObj.Height/1080)));
%     writeVideo(writerObj,mod_thisFrame);
%end


% --- Executes on button press in tableUpdate.
function tableUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to tableUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  label
label = handles.table.Data;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
