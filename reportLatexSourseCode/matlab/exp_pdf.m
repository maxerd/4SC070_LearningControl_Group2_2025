fig = get(groot,'CurrentFigure');

set(fig, 'PaperUnits', 'centimeters');
set(fig, 'Units', 'centimeters');

x_width=8.85;          %x_width of the figure, set at template column width
y_width=0.5*x_width;   %y_width of the figure, free to choose

set(fig, 'PaperPosition', [0 0 x_width y_width]); 
set(fig, 'PaperSize', [x_width y_width]); 
set(fig, 'InnerPosition', [0 0 x_width y_width]);
set(gca,'FontSize',9)

saveas(fig,'filename','pdf');   %save the figure as pdf