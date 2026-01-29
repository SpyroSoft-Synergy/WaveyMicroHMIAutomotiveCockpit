import QtQuick
import QtQuick3D

View3D {
    id: root

    property color color: Qt.color("white")
    property real densityDiffusion: 1.0
    property var points: []
    property real splatRadius: 0.001
    property var velocities: []
    property real velocityDiffusion: 0.2
    property real velocityMultiplier: 6000.
    property real vorticity: 30.

    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Color
        clearColor: "red"
        effects: [effect]
    }

    onPointsChanged: {
        var points = [];

        for (let i = 0; i < root.points.length; i++) {
            if (root.width > 0. && root.height > 0.) {
                points.push(Qt.vector3d(root.points[i].x / root.width, 1. - root.points[i].y / root.height, 1.));
            } else {
                points.push(internal.emptyPoint);
            }
        }
        internal.normalizedPoints = points;
    }
    onVelocitiesChanged: {
        var velocities = [];
        for (let i = 0; i < root.velocities.length; i++) {
            if (root.width > 0. && root.height > 0.) {
                velocities.push(Qt.vector2d(root.velocities[i].x / root.width * root.velocityMultiplier, (0. - root.velocities[i].y) / root.height * root.velocityMultiplier));
            } else {
                velocities.push(internal.emptyVelocity);
            }
        }
        internal.normalizedVelocities = velocities;
    }

    readonly property QtObject internal: QtObject {
        id: internal

        property vector4d colorAsVector: Qt.vector4d(root.color.r, root.color.g, root.color.b, root.color.a)
        readonly property vector3d emptyPoint: Qt.vector3d(0., 0., 0.)
        readonly property vector2d emptyVelocity: Qt.vector2d(0., 0.)
        property var normalizedPoints: []
        property var normalizedVelocities: []
    }

    Timer {
        id: timer

        property int counter: 0

        interval: 16
        repeat: true
        running: true

        onTriggered: counter++
    }

    OrthographicCamera {
    }

    Effect {
        id: effect

        property vector4d color: internal.colorAsVector
        property int counter: timer.counter
        property real curl: root.vorticity
        property real dissipation: 0
        property real dt: 1. / 60.
        property bool isAlphaBlend: false
        property vector3d point0: internal.normalizedPoints.length > 0 ? internal.normalizedPoints[0] : internal.emptyPoint
        property vector3d point1: internal.normalizedPoints.length > 1 ? internal.normalizedPoints[1] : internal.emptyPoint
        property vector3d point2: internal.normalizedPoints.length > 2 ? internal.normalizedPoints[2] : internal.emptyPoint
        property real pressureClear: 0.8
        property real splatRadius: root.splatRadius
        property vector2d velocity0: internal.normalizedVelocities.length > 0 ? internal.normalizedVelocities[0] : internal.emptyVelocity
        property vector2d velocity1: internal.normalizedVelocities.length > 1 ? internal.normalizedVelocities[1] : internal.emptyVelocity
        property vector2d velocity2: internal.normalizedVelocities.length > 2 ? internal.normalizedVelocities[2] : internal.emptyVelocity

        passes: [
            // splat dye
            Pass {
                output: tempRGBABuffer
                shaders: [splatDye]

                commands: [
                    SetUniformValue {
                        target: "isAlphaBlend"
                        value: true
                    },
                    BufferInput {
                        buffer: dyeBuffer
                    }
                ]
            },
            Pass {
                output: dyeBuffer
                shaders: [copy]

                commands: BufferInput {
                    buffer: tempRGBABuffer
                }
            },
            // splat velocity
            Pass {
                output: tempRGBABuffer
                shaders: [splatVelocity]

                commands: BufferInput {
                    buffer: velocityBuffer
                }
            },
            Pass {
                output: velocityBuffer
                shaders: [copy]

                commands: BufferInput {
                    buffer: tempRGBABuffer
                }
            },
            // step curl
            Pass {
                output: tempRBuffer // separate buffer not needed
                shaders: [baseVert, curl]

                commands: BufferInput {
                    buffer: velocityBuffer
                }
            },
            // step vorticity
            Pass {
                output: tempRGBABuffer
                shaders: [baseVert, vorticity]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "curlSampler"
                    },
                    BufferInput {
                        buffer: velocityBuffer
                        sampler: "velocitySampler"
                    }
                ]
            },
            Pass {
                output: velocityBuffer
                shaders: [copy]

                commands: BufferInput {
                    buffer: tempRGBABuffer
                }
            },
            // step divergence
            Pass {
                output: divergenceBuffer
                shaders: [baseVert, divergence]

                commands: BufferInput {
                    buffer: velocityBuffer
                }
            },
            // step pressure
            Pass {
                output: tempRBuffer
                shaders: [clear]

                commands: BufferInput {
                    buffer: pressureBuffer
                }
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: pressureBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: pressureBuffer
                shaders: [baseVert, pressure]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: divergenceBuffer
                        sampler: "divergenceSampler"
                    }
                ]
            },
            Pass {
                output: tempRGBABuffer
                shaders: [baseVert, gradientSubtract]

                commands: [
                    BufferInput {
                        buffer: tempRBuffer
                        sampler: "pressureSampler"
                    },
                    BufferInput {
                        buffer: velocityBuffer
                        sampler: "velocitySampler"
                    }
                ]
            },
            Pass {
                output: velocityBuffer
                shaders: [copy]

                commands: BufferInput {
                    buffer: tempRGBABuffer
                }
            },
            // advection step
            Pass {
                output: tempRGBABuffer
                shaders: [baseVert, advection]

                commands: [
                    SetUniformValue {
                        target: "dissipation"
                        value: root.velocityDiffusion
                    },
                    BufferInput {
                        buffer: velocityBuffer
                        sampler: "velocitySampler"
                    },
                    BufferInput {
                        buffer: velocityBuffer
                        sampler: "sourceSampler"
                    }
                ]
            },
            Pass {
                output: velocityBuffer
                shaders: [copy]

                commands: BufferInput {
                    buffer: tempRGBABuffer
                }
            },
            Pass {
                output: tempRGBABuffer
                shaders: [baseVert, advection]

                commands: [
                    SetUniformValue {
                        target: "dissipation"
                        value: root.densityDiffusion
                    },
                    BufferInput {
                        buffer: velocityBuffer
                        sampler: "velocitySampler"
                    },
                    BufferInput {
                        buffer: dyeBuffer
                        sampler: "sourceSampler"
                    }
                ]
            },
            Pass {
                output: dyeBuffer
                shaders: [copy]

                commands: BufferInput {
                    buffer: tempRGBABuffer
                }
            },
            // output result
            Pass {
                shaders: [copy]

                commands: BufferInput {
                    buffer: dyeBuffer
                }
            }
        ]

        Buffer {
            id: tempRGBABuffer

            format: Buffer.RGBA16F
            name: "tempRGBABuffer"
        }

        Buffer {
            id: tempRBuffer

            format: Buffer.R16F
            name: "tempRBuffer"
        }

        Buffer {
            id: dyeBuffer

            format: Buffer.RGBA16F
            name: "dyeBuffer"
        }

        Buffer {
            id: velocityBuffer

            format: Buffer.RGBA16F
            name: "velocityBuffer"
        }

        Buffer {
            id: divergenceBuffer

            format: Buffer.R16F
            name: "divergenceBuffer"
        }

        Buffer {
            id: pressureBuffer

            format: Buffer.R16F
            name: "pressureBuffer"
        }

        Shader {
            id: baseVert

            shader: "shaders/base.vert"
            stage: Shader.Vertex
        }

        Shader {
            id: copy

            shader: "shaders/copy.frag"
        }

        Shader {
            id: splatDye

            shader: "shaders/splatDye.frag"
        }

        Shader {
            id: splatVelocity

            shader: "shaders/splatVelocity.frag"
        }

        Shader {
            id: curl

            shader: "shaders/curl.frag"
        }

        Shader {
            id: vorticity

            shader: "shaders/vorticity.frag"
        }

        Shader {
            id: divergence

            shader: "shaders/divergence.frag"
        }

        Shader {
            id: clear

            shader: "shaders/clear.frag"
        }

        Shader {
            id: pressure

            shader: "shaders/pressure.frag"
        }

        Shader {
            id: gradientSubtract

            shader: "shaders/gradientSubtract.frag"
        }

        Shader {
            id: advection

            shader: "shaders/advection.frag"
        }
    }
}
