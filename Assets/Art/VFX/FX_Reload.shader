// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_Reload"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Texture("Texture", 2D) = "white" {}
		_HDR("HDR", Float) = 0
		_L_Min("L_Min", Float) = 0
		_L_MAX("L_MAX", Float) = 0
		_V_X_Pan("V_X_Pan", Float) = 0
		_V_Scale("V_Scale", Float) = 0
		_V_Angle_Speed("V_Angle_Speed", Float) = 0
		_V_Y_Pan("V_Y_Pan", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}


	Category
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull Off
			Lighting Off
			ZWrite Off
			ZTest LEqual
			
			Pass {

				CGPROGRAM
				#define ASE_VERSION 19801

				#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
				#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
				#endif

				#pragma vertex vert
				#pragma fragment frag
				#pragma target 3.5
				#pragma multi_compile_instancing
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				#include "UnityShaderVariables.cginc"
				#define ASE_NEEDS_FRAG_COLOR


				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
					
				};


				#if UNITY_VERSION >= 560
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				#else
				uniform sampler2D_float _CameraDepthTexture;
				#endif

				//Don't delete this comment
				// uniform sampler2D_float _CameraDepthTexture;

				uniform sampler2D _MainTex;
				uniform fixed4 _TintColor;
				uniform float4 _MainTex_ST;
				uniform float _InvFade;
				uniform float _L_Min;
				uniform float _L_MAX;
				uniform float _V_Scale;
				uniform float _V_Angle_Speed;
				uniform float _V_X_Pan;
				uniform float _V_Y_Pan;
				uniform sampler2D _Texture;
				uniform float4 _Texture_ST;
				uniform float _HDR;
				struct Gradient
				{
					int type;
					int colorsLength;
					int alphasLength;
					float4 colors[8];
					float2 alphas[8];
				};
				
				Gradient NewGradient(int type, int colorsLength, int alphasLength, 
				float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
				float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
				{
					Gradient g;
					g.type = type;
					g.colorsLength = colorsLength;
					g.alphasLength = alphasLength;
					g.colors[ 0 ] = colors0;
					g.colors[ 1 ] = colors1;
					g.colors[ 2 ] = colors2;
					g.colors[ 3 ] = colors3;
					g.colors[ 4 ] = colors4;
					g.colors[ 5 ] = colors5;
					g.colors[ 6 ] = colors6;
					g.colors[ 7 ] = colors7;
					g.alphas[ 0 ] = alphas0;
					g.alphas[ 1 ] = alphas1;
					g.alphas[ 2 ] = alphas2;
					g.alphas[ 3 ] = alphas3;
					g.alphas[ 4 ] = alphas4;
					g.alphas[ 5 ] = alphas5;
					g.alphas[ 6 ] = alphas6;
					g.alphas[ 7 ] = alphas7;
					return g;
				}
				
						float2 voronoihash49( float2 p )
						{
							
							p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
							return frac( sin( p ) *43758.5453);
						}
				
						float voronoi49( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
						{
							float2 n = floor( v );
							float2 f = frac( v );
							float F1 = 8.0;
							float F2 = 8.0; float2 mg = 0;
							for ( int j = -1; j <= 1; j++ )
							{
								for ( int i = -1; i <= 1; i++ )
							 	{
							 		float2 g = float2( i, j );
							 		float2 o = voronoihash49( n + g );
									o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
									float d = 0.5 * dot( r, r );
							 		if( d<F1 ) {
							 			F2 = F1;
							 			F1 = d; mg = g; mr = r; id = o;
							 		} else if( d<F2 ) {
							 			F2 = d;
							
							 		}
							 	}
							}
							return F1;
						}
				
				float4 SampleGradient( Gradient gradient, float time )
				{
					float3 color = gradient.colors[0].rgb;
					UNITY_UNROLL
					for (int c = 1; c < 8; c++)
					{
					float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
					color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
					}
					#ifndef UNITY_COLORSPACE_GAMMA
					color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
					#endif
					float alpha = gradient.alphas[0].x;
					UNITY_UNROLL
					for (int a = 1; a < 8; a++)
					{
					float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
					alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
					}
					return float4(color, alpha);
				}
				


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( i );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( i );

					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					Gradient gradient19 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0.3339622, 0.7414204, 1, 0.997055 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
					float2 temp_cast_0 = (_V_Angle_Speed).xx;
					float2 panner51 = ( 1.0 * _Time.y * temp_cast_0 + float2( 0,0 ));
					float time49 = panner51.x;
					float2 voronoiSmoothId49 = 0;
					float2 appendResult57 = (float2(_V_X_Pan , _V_Y_Pan));
					float2 texCoord52 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner50 = ( 1.0 * _Time.y * appendResult57 + texCoord52);
					float2 coords49 = panner50 * _V_Scale;
					float2 id49 = 0;
					float2 uv49 = 0;
					float voroi49 = voronoi49( coords49, time49, id49, uv49, 0, voronoiSmoothId49 );
					float smoothstepResult18 = smoothstep( _L_Min , _L_MAX , voroi49);
					float2 uv_Texture = i.texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
					float4 temp_output_12_0 = ( tex2D( _Texture, uv_Texture ) * i.color );
					float4 appendResult23 = (float4(( (temp_output_12_0).rgb * _HDR ) , (temp_output_12_0).a));
					

					fixed4 col = ( SampleGradient( gradient19, smoothstepResult18 ) * appendResult23 );
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG
			}
		}
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.RangedFloatNode;53;-2480,-368;Inherit;False;Property;_V_X_Pan;V_X_Pan;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2464,-256;Inherit;False;Property;_V_Y_Pan;V_Y_Pan;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;9;-1344,320;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-1424,48;Inherit;True;Property;_Texture;Texture;0;0;Create;True;0;0;0;False;0;False;-1;None;fcf54ec8b96773c4e94018c6da6b96ed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-2336,-496;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;57;-2192,-352;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2315.521,-51.6701;Inherit;False;Property;_V_Scale;V_Scale;5;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2320,-128;Inherit;False;Property;_V_Angle_Speed;V_Angle_Speed;6;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1120,256;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;51;-1984,-320;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;50;-1984,-480;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;58;-1856,-64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-720,496;Inherit;False;Property;_HDR;HDR;1;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;17;-976,256;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VoronoiNode;49;-1664,-448;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;15;-1424,-80;Inherit;False;Property;_L_MAX;L_MAX;3;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1472,-192;Inherit;False;Property;_L_Min;L_Min;2;0;Create;True;0;0;0;False;0;False;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;18;-1152,-336;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;19;-1056,-496;Inherit;False;0;2;2;1,1,1,0;0.3339622,0.7414204,1,0.997055;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-720,256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;-960,352;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;22;-784,-368;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;23;-544,256;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-368,-128;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;11;FX_Reload;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;57;0;53;0
WireConnection;57;1;54;0
WireConnection;12;0;10;0
WireConnection;12;1;9;0
WireConnection;51;2;55;0
WireConnection;50;0;52;0
WireConnection;50;2;57;0
WireConnection;58;0;56;0
WireConnection;17;0;12;0
WireConnection;49;0;50;0
WireConnection;49;1;51;0
WireConnection;49;2;58;0
WireConnection;18;0;49;0
WireConnection;18;1;14;0
WireConnection;18;2;15;0
WireConnection;20;0;17;0
WireConnection;20;1;16;0
WireConnection;21;0;12;0
WireConnection;22;0;19;0
WireConnection;22;1;18;0
WireConnection;23;0;20;0
WireConnection;23;3;21;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;0;0;24;0
ASEEND*/
//CHKSM=A0494114199A7B9FF79806408EE901ECDC812C39