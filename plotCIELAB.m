function plotCIELAB(R, luminocity)
% plotCIELAB - Visualizes the CIELAB color disk in the a*-b* plane.
%
% Syntax:
%   plotCIELAB(R, luminocity)
%
% Description:
%   This function plots a CIELAB "disk" in the a*-b* plane,
%   ensuring that 0°, 90°, 180°, and 270° correspond to Red, Yellow,
%   Green, and Blue, respectively. The user specifies a single radius R
%   and a luminocity factor that adjusts the brightness of the colors.
%
% Input:
%   R          : Radius of the color disk (positive scalar).
%   luminocity : Brightness factor (scalar between 0 and 1).
%
% Example:
%   plotCIELAB(100, 0.8);

    %% Input Validation
    if nargin < 2
        luminocity = 1; % Default luminocity if not provided
    end
    
    validateattributes(R, {'numeric'}, {'scalar', 'positive'}, mfilename, 'R', 1);
    validateattributes(luminocity, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, mfilename, 'luminocity', 2);
    
    %% Define Axis Limits
    aMin = -R; 
    aMax =  R;
    bMin = -R;
    bMax =  R;

    %% Define Colors
    cRed    = [1, 0,   0] * luminocity;
    cYellow = [1, 1, 0] * luminocity;
    cGreen  = [0, 1, 0] * luminocity;
    cBlue   = [0, 0, 1] * luminocity;
    cGray   = [1, 1, 1] * luminocity;  % Central color at the origin

    %% Prepare Figure
    figure('Color','white');
    hold on;
    axis equal;
    box on;
    set(gca, 'FontSize', 14);
    xlabel('$a^\star$', 'Interpreter', 'latex');
    ylabel('$b^\star$', 'Interpreter', 'latex');
    axis([aMin aMax bMin bMax]);

    %% Draw Central Axes
    plot([aMin aMax], [0 0], 'k', 'LineWidth', 1); % a* axis
    plot([0 0], [bMin bMax], 'k', 'LineWidth', 1); % b* axis

    %% Define Quadrant Angles and Colors
    quadrants = {
        struct('startAngle', 0,   'endAngle', 90,  'startColor', cRed,    'endColor', cYellow),
        struct('startAngle', 90,  'endAngle', 180, 'startColor', cYellow, 'endColor', cGreen),
        struct('startAngle', 180, 'endAngle', 270, 'startColor', cGreen,  'endColor', cBlue),
        struct('startAngle', 270, 'endAngle', 360, 'startColor', cBlue,   'endColor', cRed)
    };

    %% Create and Draw Patches for Each Quadrant
    for q = 1:length(quadrants)
        patchVertices = [];
        patchColors = [];
        
        angles = quadrants{q}.startAngle : 1 : quadrants{q}.endAngle;
        
        for theta = angles
            [aVal, bVal] = pol2cartd(theta, R);
            patchVertices(end+1, :) = [aVal, bVal];
            
            % Linear interpolation between startColor and endColor
            t = (theta - quadrants{q}.startAngle) / (quadrants{q}.endAngle - quadrants{q}.startAngle);
            currentColor = (1 - t) * quadrants{q}.startColor + t * quadrants{q}.endColor;
            patchColors(end+1, :) = currentColor;
        end
        
        % Append the origin to close the patch
        patchVertices(end+1, :) = [0, 0];
        patchColors(end+1, :) = cGray;
        
        % Draw the patch with interpolated colors
        patch('Vertices', patchVertices, ...
              'Faces', 1:size(patchVertices,1), ...
              'FaceVertexCData', patchColors, ...
              'FaceColor', 'interp', ...
              'EdgeColor', 'none');
    end

    %% Redraw Central Axes on Top
    plot([aMin aMax], [0 0], 'k', 'LineWidth', 1);
    plot([0 0], [bMin bMax], 'k', 'LineWidth', 1);

    hold off;
end

%% Helper Function: Convert Polar to Cartesian Coordinates
function [x, y] = pol2cartd(theta, r)
% pol2cartd - Converts polar coordinates (degrees) to Cartesian coordinates.
%
% Syntax:
%   [x, y] = pol2cartd(theta, r)
%
% Description:
%   Converts an angle in degrees and radius to Cartesian (x, y) coordinates.
%
% Input:
%   theta : Angle in degrees.
%   r     : Radius.
%
% Output:
%   x : Cartesian x-coordinate.
%   y : Cartesian y-coordinate.

    radians = deg2rad(theta);
    x = r * cos(radians);
    y = r * sin(radians);
end