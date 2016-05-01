//
//  RectangleGenerator.swift
//  GPUImage-iOS
//
//  Created by Błażej Szajrych on 30.04.2016.
//  Copyright © 2016 Sunset Lake Software LLC. All rights reserved.
//

#if os(Linux)
#if GLES
    import COpenGLES.gles2
    #else
    import COpenGL
#endif
#else
#if GLES
    import OpenGLES
    #else
    import OpenGL.GL
#endif
#endif

protocol GLEndpointsConvertible {
    func toGLEndpoints() -> [GLfloat]
}

public protocol GeometryDrawable {
    func toPoints() -> [Point]
}

public struct Point: GLEndpointsConvertible {
    var x: Float
    var y: Float
    
    public init(x: Float, y: Float)
    {
        self.x = x
        self.y = y
    }
    
    func toGLEndpoints() -> [GLfloat] {
        return [x, y]
    }
}

public struct Rectangle: GeometryDrawable {
    
    private var points = [Point]()
    
    public init(leftBottom: Point, rightBottom: Point, topRight: Point, leftTop: Point) {
        points.append(leftBottom)
        points.append(rightBottom)
        points.append(topRight)
        
        points.append(topRight)
        points.append(leftTop)
        points.append(leftBottom)
    }
    
    public func toPoints() -> [Point] {
        return self.points
    }
}

public class GeometryItemGenerator: ImageGenerator {
    
    private struct Constants {
        static let colorKey = "lineColor"
        static let positionKey = "position"
        static let shaderName = "LineGenerator"
    }
    
    public var lineColor:Color = Color.Green { didSet { uniformSettings[Constants.colorKey] = lineColor } }
    
    let lineShader:ShaderProgram
    var uniformSettings = ShaderUniformSettings()
    
    public override init(size:Size) {
        lineShader = crashOnShaderCompileFailure(Constants.shaderName){try sharedImageProcessingContext.programForVertexShader(LineVertexShader, fragmentShader:LineFragmentShader)}
        super.init(size:size)
        
        ({lineColor = Color.Red})()
    }
    
    
    public func renderGeometryItem(item: GeometryDrawable) {
        self.renderGeometryItems([item])
    }
    
    public func renderGeometryItems(items: [GeometryDrawable]) {
        imageFramebuffer.activateFramebufferForRendering()
        
        lineShader.use()
        uniformSettings.restoreShaderSettings(lineShader)
        
        clearFramebufferWithColor(Color.Transparent)
        
        guard let positionAttribute = lineShader.attributeIndex(Constants.positionKey) else { fatalError("A position attribute was missing from the shader program during rendering.") }
        
        let singleVertexValueCount: GLsizei = 2

        glEnableClientState(GLenum(GL_VERTEX_ARRAY));
        
        let transY: GLfloat = 0.0
        glTranslatef(0.0, (GLfloat)(sinf(transY)/2.0), 0.0);
        
        glBlendEquation(GLenum(GL_FUNC_ADD))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE))
        glEnable(GLenum(GL_BLEND))
        
        for drawable in items {
            let points = drawable.toPoints()
            let vertexValues = points.flatMap({ (point) -> [GLfloat] in
                return point.toGLEndpoints()
            })
            
            glVertexAttribPointer(positionAttribute, singleVertexValueCount, GLenum(GL_FLOAT), 0, 0, vertexValues)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(points.count));
        }
        
        glDisable(GLenum(GL_BLEND))

        
        notifyTargets()
    }
    

}
