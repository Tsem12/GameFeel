// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Spaceship_Trail"
{
	Properties
	{
		_Tex_HDR("Tex_HDR", Float) = 5.05
		_Trail_intensity("Trail_intensity", Range( 0 , 1)) = 1
		_Noisetilling("Noise tilling", Float) = 0.48
		_Tex_Noise_Trail_Spaceship("Tex_Noise_Trail_Spaceship", 2D) = "white" {}
		_Tex_Trail_Spaceship("Tex_Trail_Spaceship", 2D) = "white" {}

	}

	SubShader
	{
		

		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		

		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#define ASE_VERSION 19801


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Tex_Noise_Trail_Spaceship;
			uniform float _Noisetilling;
			uniform float _Trail_intensity;
			uniform sampler2D _Tex_Trail_Spaceship;
			uniform float _Tex_HDR;
			float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
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
			


			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}

			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 texCoord12 = i.ase_texcoord1.xy * ( float2( -1.42,-0.14 ) * _Noisetilling ) + float2( 1,1 );
				float2 panner18 = ( 2.1 * _Time.y * float2( 0,0.25 ) + texCoord12);
				float2 texCoord36 = i.ase_texcoord1.xy * tex2D( _Tex_Noise_Trail_Spaceship, panner18 ).rg + float2( 0,0 );
				float smoothstepResult58 = smoothstep( 0.0 , 0.18 , ( ( 0.0 + -( texCoord36.y - 0.2 ) ) * _Trail_intensity ));
				float2 texCoord81 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_44_0 = saturate( ( smoothstepResult58 * ( 1.0 - texCoord81.y ) ) );
				Gradient gradient46 = NewGradient( 1, 3, 2, float4( 0.3481776, 0.9339623, 0.3207191, 0.3235371 ), float4( 0.4025705, 0.8207547, 0.2199003, 0.7323567 ), float4( 0.4996668, 0.9528302, 0.2193307, 1 ), 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
				float2 texCoord79 = i.ase_texcoord1.xy * float2( 1,-0.01 ) + float2( -0.14,0.75 );
				float2 panner78 = ( 1.0 * _Time.y * float2( 0,0.39 ) + texCoord79);
				float3 hsvTorgb48 = RGBToHSV( SampleGradient( gradient46, tex2D( _Tex_Trail_Spaceship, panner78 ).rgb.x ).rgb );
				float3 hsvTorgb55 = HSVToRGB( float3(( hsvTorgb48.x + 1.0 ),( hsvTorgb48.y * 1.0 ),( hsvTorgb48.z * 1.0 )) );
				float4 appendResult76 = (float4(( temp_output_44_0 * ( hsvTorgb55 * _Tex_HDR ) ) , temp_output_44_0));
				

				finalColor = appendResult76;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.Vector2Node;13;-2368,320;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;-1.42,-0.14;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;17;-2304,640;Inherit;False;Property;_Noisetilling;Noise tilling;2;0;Create;True;0;0;0;False;0;False;0.48;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2080,496;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1888,496;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;18;-1648,704;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.25;False;1;FLOAT;2.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;10;-1392,752;Inherit;True;Property;_Tex_Noise_Trail_Spaceship;Tex_Noise_Trail_Spaceship;3;0;Create;True;0;0;0;False;0;False;-1;8fda172b188d7f342ba64c2c53acc2e4;8fda172b188d7f342ba64c2c53acc2e4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;37;-720,896;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-736,736;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;79;-1584,-160;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,-0.01;False;1;FLOAT2;-0.14,0.75;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;45;-640,-208;Inherit;False;1217.223;706.4607;Comment;12;57;56;55;54;53;52;51;50;49;48;47;46;Color Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;78;-1280,-64;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.39;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-496,816;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;46;-624,-128;Inherit;False;1;3;2;0.3481776,0.9339623,0.3207191,0.3235371;0.4025705,0.8207547,0.2199003,0.7323567;0.4996668,0.9528302,0.2193307,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SamplerNode;77;-976,-64;Inherit;True;Property;_Tex_Trail_Spaceship;Tex_Trail_Spaceship;4;0;Create;True;0;0;0;False;0;False;-1;8fda172b188d7f342ba64c2c53acc2e4;8fda172b188d7f342ba64c2c53acc2e4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.NegateNode;40;-256,816;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;47;-608,0;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;41;64,640;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;112,976;Inherit;False;Property;_Trail_intensity;Trail_intensity;1;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-528,272;Inherit;False;Constant;_saturation;saturation;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-352,368;Inherit;False;Constant;_value;value;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-272,0;Inherit;False;Constant;_Hue2;Hue;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;48;-352,144;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;416,736;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-319.2869,1207.167;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-96,304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-96,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-64,16;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;58;688,720;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.18;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;592,1184;Inherit;True;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;55;112,144;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;56;336,208;Inherit;False;Property;_Tex_HDR;Tex_HDR;0;0;Create;True;0;0;0;False;0;False;5.05;12.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;960,704;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;368,-96;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;44;1104,608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;1248,272;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;76;1600,400;Inherit;False;COLOR;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;74;1936,400;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;100;5;Spaceship_Trail;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;2;5;False;;10;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;16;0;13;0
WireConnection;16;1;17;0
WireConnection;12;0;16;0
WireConnection;18;0;12;0
WireConnection;10;1;18;0
WireConnection;36;0;10;0
WireConnection;78;0;79;0
WireConnection;35;0;36;2
WireConnection;35;1;37;0
WireConnection;77;1;78;0
WireConnection;40;0;35;0
WireConnection;47;0;46;0
WireConnection;47;1;77;5
WireConnection;41;1;40;0
WireConnection;48;0;47;0
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;53;0;48;3
WireConnection;53;1;51;0
WireConnection;52;0;48;2
WireConnection;52;1;50;0
WireConnection;54;0;48;1
WireConnection;54;1;49;0
WireConnection;58;0;42;0
WireConnection;82;1;81;2
WireConnection;55;0;54;0
WireConnection;55;1;52;0
WireConnection;55;2;53;0
WireConnection;83;0;58;0
WireConnection;83;1;82;0
WireConnection;57;0;55;0
WireConnection;57;1;56;0
WireConnection;44;0;83;0
WireConnection;75;0;44;0
WireConnection;75;1;57;0
WireConnection;76;0;75;0
WireConnection;76;3;44;0
WireConnection;74;0;76;0
ASEEND*/
//CHKSM=3A332845C3E0D940DFBF68E3DEFD647B1AEE7380