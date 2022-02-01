% Filtering images
function [output_image] = filters(raw_image, sensitivity)

filtered_image = raw_image(:,:,:); % Loads image
filtered_image = rgb2gray(filtered_image); % Transform image to grayscale. Comment this line if the photos are already in that format.
filtered_image = ~imbinarize(filtered_image, 'adaptive','Sensitivity', sensitivity); % Binarize with an adaptative thresold with a defined sensitivity.
filtered_image = ~imfill(filtered_image,'holes'); % Fill eventual holes in detected particles.
filtered_image = ~imclearborder(~filtered_image); % Remove particles touching the borders.

output_image = filtered_image;