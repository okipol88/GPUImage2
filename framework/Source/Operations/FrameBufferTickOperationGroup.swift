//
//  FrameBufferTickOperationGroup.swift
//  GPUImage-iOS
//
//  Created by user on 01.05.2016.
//  Copyright © 2016 Sunset Lake Software LLC. All rights reserved.
//

public class FrameBufferTickOperationGroup: OperationGroup {
    
    public var newFrameAvaialableTick: (() -> ())? = nil
    
    public override init() {
        super.init()
    }
    
    public override func newFramebufferAvailable(framebuffer:Framebuffer, fromSourceIndex:UInt) {
        super.newFramebufferAvailable(framebuffer, fromSourceIndex: fromSourceIndex)
        
        self.newFrameAvaialableTick?()
    }
    
}
