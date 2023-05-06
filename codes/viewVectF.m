function viewVectF(Coord,Vect)

quiver3(Coord(:,1),Coord(:,2),Coord(:,3),Vect(:,1),Vect(:,2),Vect(:,3),...
    'Color','r','LineWidth',1,'AutoScale','on');
