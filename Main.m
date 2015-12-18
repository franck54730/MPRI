function main()
    KPP = 3;
    img = lectureImage();
    face_recognition(img,3);
end

function img = lectureImage()
    [img_name, img_path] = uigetfile('*.png');
    fname = fullfile(img_path, img_name);
    img = imread(fname);
end