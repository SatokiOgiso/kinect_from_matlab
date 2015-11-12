clear

myobj = kinectIrRead()
while 1
    imagesc(myobj.Get2DImage()')
    axis equal
    pause(0.1)
end

