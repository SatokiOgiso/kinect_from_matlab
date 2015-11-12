classdef kinectIrRead
    properties
        kinectSensor = [];
        infraredFrameReader = [];
        infraredFrameData = [];
        infraredFrameDescription = [];
        callback;
    end

    methods
        function obj = kinectIrRead(varargin)
            
            NET.addAssembly('C:\Program Files\Microsoft SDKs\Kinect\v2.0_1409\Assemblies\Microsoft.Kinect.dll');

            obj.callback = varargin;
            
            obj.kinectSensor =  Microsoft.Kinect.KinectSensor.GetDefault();

            % get the infraredFrameDescription from the 
            % InfraredFrameSource
            obj.infraredFrameDescription = ...
                obj.kinectSensor.InfraredFrameSource.FrameDescription;

            % open the reader for the infrared frames
            obj.infraredFrameReader = ...
                obj.kinectSensor.InfraredFrameSource.OpenReader();
            
            % allocate space to put the pixels being
            % received and converged
            obj.infraredFrameData = ...
                NET.createArray('System.UInt16', ...
                    obj.infraredFrameDescription.Width * ...
                    obj.infraredFrameDescription.Height);
                
            %write handler for frame arrival
            addlistener(obj.infraredFrameReader, 'FrameArrived', ...
                @obj.Reader_InfraredFrameArrived);

            obj.kinectSensor.Open();
            
        end
        
        function Close(obj)
            obj.kinectSensor.Close(); 
        end

        function Reader_InfraredFrameArrived(obj, sender, arg)
            infraredFrameProcessed = false;

            infraredFrame = arg.FrameReference.AcquireFrame();
            if ~isnumeric(infraredFrame)
                obj.infraredFrameDescription = infraredFrame.FrameDescription;
                if (((obj.infraredFrameDescription.Width * ...
                    obj.infraredFrameDescription.Height) ...
                    == obj.infraredFrameData.Length))
                    infraredFrame.CopyFrameDataToArray(obj.infraredFrameData);

                    infraredFrameProcessed = true;
                end
                
                infraredFrame.Dispose();
            end
            
            if infraredFrameProcessed
                if isa(obj.callback, 'function_handle')
                    obj.callback(obj.Get2DImage());
                end
            end
        end
        
        function irImage = Get2DImage(obj)
            irImage = reshape(double(obj.infraredFrameData), [], ...
                obj.infraredFrameDescription.Height);
        end
        
    end
end
