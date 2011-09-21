I = 'image_0058.jpg';
bin = 8;
angle = 180;
L=2;
roi = [1;225;1;300];
I = imread(I);
p = anna_phog(I,bin,angle,L)
