classdef MotionFlowData
    %MOTIONFLOWDATA  Class representing data from the motion flow analysis
    %
    %  OBJ = MOTIONFLOWDATA(filename) loads the data in the MAT-file
    %  location specified in filename.
    %
    %  If no center of beating has been identified yet, run the command
    %  findCenterOfBeating.


    properties

        X = [];
        Y = [];
        U = [];
        V = [];
        nd2File = '';
        centerOfBeating = [];
        CoBROI = [];
        
    end

    methods

        function obj = MotionFlowData(varargin)
            %MOTIONFLOWDATA  Construct a new MotionFlowData object
            %
            %  OBJ = MOTIONFLOWDATA(filename) 
            
            if numel(varargin) == 1

                obj = importdata(obj, varargin{1});
                
            end

        end

        function obj = importdata(obj, filename)

            %Load the data
            data = load(filename);

            obj.X = data.storeX;
            obj.Y = data.storeY;
            obj.U = data.storeU;
            obj.V = data.storeV;

            obj.nd2File = data.inputFile;

        end

        function obj = findCenterofBeating(obj)

            %Create a reader object 
              %Load the image
            reader = BioformatsImage(inputFile);

            I = getPlane(reader, 1, 1, 1);

            imshow(I, [])

            roi = drawrectangle;  %roi = [xmin, ymin, width, height]
            wait(roi);

            xmin = round(roi.Position(1));
            ymin = round(roi.Position(2));
            width = round(roi.Position(3));
            height = round(roi.Position(4));

            Cx = xmin:(xmin + width);
            Cy = ymin:(ymin + height);

            [Cx, Cy] = meshgrid(Cx, Cy);

            meanMotion = zeros([size(Cx), reader.sizeT]);
            for iT = 1:reader.sizeT

                meanMotion(:, :, iT) = MFA.computeMotion(storeX, storeY, storeU(:, :, iT), storeV(:, :, iT), Cx, Cy);

            end

            %Find the center of beating
            modeContraction = mode(round(meanMotion, 5, 'significant'), 3);
            meanMotionNorm = meanMotion - modeContraction;

            %Compute the maximum value (max contraction)
            maxContraction = max(meanMotionNorm, [], 3);

            %Compute the minimum value (max dilation)
            minContraction = min(meanMotionNorm, [], 3);

            %Compute the difference in contraction values
            diffContraction = maxContraction + minContraction;

            %Find the position of the smallest difference
            [iCoB, jCoB] = find(diffContraction == min(diffContraction, [], 'all'));

            xCoB = jCoB + xmin;
            yCoB = iCoB + ymin;



        end
    end


end