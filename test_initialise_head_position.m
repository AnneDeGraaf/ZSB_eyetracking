% cam = webcam;

stream = preview(cam);

rectangle = insertShape(stream, 'rectangle', [210, 330, 220, 250], 'Color', 'red', 'LineWidth', 5);
