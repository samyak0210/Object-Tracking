frame = imread('img/0001.jpg');
[img, rect] = imcrop(frame);
close;
points = detectMinEigenFeatures(rgb2gray(frame), 'ROI', rect);

rectpoints = bbox2points(rect(1,:));

tracker = vision.PointTracker('MaxBidirectionalError', 2);
points = points.Location;
initialize(tracker, points, frame);

oldPoints = points;

for i=2:500
    s = int2str(i);
    string = 'img/';
    for j=1:4-length(s)
        string = strcat(string,'0');
    end
    string = strcat(string,s,'.jpg');
    frame = imread(string);
    [points, idx] = step(tracker, frame);
    
    new = points(idx, :);
    old = oldPoints(idx, :);
    
    if size(new, 1) >= 2
        [mat, old, new] = estimateGeometricTransform(old, new, 'similarity', 'MaxDistance', 4);
        rectpoints = transformPointsForward(mat, rectpoints);
        bbox = reshape(rectpoints', 1, []);
        frame = insertShape(frame, 'Polygon', bbox, 'LineWidth', 2);
        oldPoints = new;
        setPoints(tracker, oldPoints);
        imwrite(frame, strcat('result/',s,'.png'));
    end
end