// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "aburafia/kodelife"
{
	Properties
	{
		_pasttime ("pasttime", float) = 0
		_volume ("volume", float) = 0
		_maintex("main texture",2D) = "white" {}
        _prevframe("prev frame",2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Cull Off 
		//ZWrite Off
		//ZTest Off

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
            #include "UnityCG.cginc"
            #include "kodelife.cginc"

			struct appdata
			{
                
				float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
               

			};

			struct v2f
			{
				float4 clip_ver : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float4 model_ver : TEXCOORD1; 
                float4 world_ver : TEXCOORD2;
                float4 correctgrabuv : TEXCOORD3;
                float2 grabuv : TEXCOORD4;

			};

			float time;
			float _volume;
            sampler2D _MainTex;
            sampler2D _prevframe;

			v2f vert (appdata v)
			{
				v2f o;
                o.model_ver = v.vertex;
                o.world_ver = mul(unity_ObjectToWorld,v.vertex);
				o.clip_ver = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex;


                //http://light11.hatenadiary.com/entry/2018/06/13/235543
                //proj座標から、スクリーン上の座標を算出する。UnityObjectToClipPos使えばいいけど、生で
                float4 compscreen = o.clip_ver;
                //DirectXとかOpenglとかの依存をこれでなくす
                compscreen.y *= _ProjectionParams.x;
                //proj座標だから、-wからwまでとる。
                //だから、wで割ると、-1〜1。*0.5+0.5で、0〜1
                //ComputeGrabScreenPos使えばいいけど、生で
                o.grabuv = compscreen.xy/compscreen.z * 0.5 + 0.5;
                o.correctgrabuv = ComputeScreenPos(o.clip_ver);


				return o;
			}


            //座標系によっていろいろかわるよねーってテスト
            fixed4 checkCordinate(v2f i){
                float noise_local = cnoise((i.model_ver.xyz*10)+_Time) > time ? 0: 1;
                float noise_world = cnoise((i.world_ver.xyz*10)+_Time) > time ? 0: 1;
                float noise_view = cnoise((i.clip_ver.xyz/50)+_Time) > time ? 0: 1;

                float w = noise_local;
                fixed4 col = fixed4(w,w,w,1);

                return col;
            }

            float2 rnd2(float2 v, int seed){

                return float2(rnd(v,seed*2),rnd(v,seed*3));
            }

            float3 rnd3(float3 v, float seed){

                //座標のxyzの場所を含まれないものでつかったら、いい感じ。xのところなら、yzとか
                return float3(rnd(v.zy,seed*4),rnd(v.xz,seed*2),rnd(v.yx,seed*3));
            }

            float2 cnoise2(float2 v){
                float time = _Time * 100;
                return float2(
                    cnoise(float3(v,time + 0.1)) ,
                    cnoise(float3(v,time + 1.1)) 
                );
            }

            float2 noise2(float2 v){
                //noiseの中ではfracでみるところがあるから、整数値だけだと、タイミングが揃ってしまう。
                //半端な数値が必要
                float t = _Time;
                float time = t * 10 + v.x*3.1737 + v.y*3.7175;
                return float2(
                    noise(float2(v.y,time * 1)) ,
                    noise(float2(v.x,time * 1.1)) 
                );
            }

            float2 tikaku_noise2(float2 v){

            }

            //セルノイズが楽しそうだから実装してみよう
            fixed4 cellNoise(v2f i){


                float4 prevcolor = tex2Dproj(_prevframe, i.correctgrabuv);

                float3 xyz = i.world_ver.xyz*2;

                float time = _Time * 0.0001;

                float w = frac(xyz.x)*0.1 + frac(xyz.y)*0.1 + frac(xyz.z)*0.1 ;

                float2 myarea = floor(xyz.xy);
                float2 mypoint = frac(xyz.xy);

                //mapかけたい
                //float noise_local = cnoise2(nowpoint+_Time*10);

                //2dなら
                //float rp = distance(frac(xyz.xy),  cnoise2(floor(xyz.xy) ) ) < 0.1 ? 1 : 0;
                //float rp = distance(frac(xyz) , rnd3(floor(xyz)) ) < 0.3 ? 1 : 0;

                float r = 0;
                float g = 0;
                float b = 0;

                //枠線
                r = abs(xyz.x - floor(xyz.x)) > 0.99 ? 1 : 0;
                r += abs(xyz.y - floor(xyz.y)) > 0.99 ? 1 : 0;
                r += abs(xyz.z - floor(xyz.z)) > 0.99 ? 1 : 0;

                //ランダムの点を描画
                float2 noisePointByFloor = (noise2(myarea));
                b = distance(mypoint,  noisePointByFloor ) < 0.03 ? 1 : 0;

                float minimumdist = 1.;
                float minimumdist2 = 1.;


                //float2 nearest1st;
                //float2 nearest2st;

                //８方向のランダム点から一番ちいさいいろを描画
                for(int x = -1; x<= 1; x++){ 
                for(int y = -1; y<= 1; y++){
                    float2 neighbor = float2(x,y);

                    //隣のエリアの中のランダムポイント
                    float random_point = noise2(myarea + neighbor);

                    float2 random_world_point = random_point + neighbor;

                    //自分と、(隣のエリアのランダムポイント+隣のエリア) の距離。
                    float dist = distance(mypoint,  random_world_point ) ;

                    //minimumdist = minimumdist > dist ? dist : minimumdist;

                    if(minimumdist > dist){
                        minimumdist = dist;
                    }else{
                        if(minimumdist2 > dist){
                            minimumdist2 = dist;
                        }
                    }

                }
                }


                //g = minimumdist ;
                float mindist = abs(minimumdist - minimumdist2);
                g = mindist < 0.01 ? 1: 0;

                r += minimumdist < 0.1 ? 1 : r ;

                g +=  (prevcolor.g * _volume);             
                b += (prevcolor.b * _volume);             


                fixed4 col = fixed4(r,g,b,1);
                return col;

            }


			fixed4 frag (v2f i) : SV_Target
			{
				return cellNoise(i);
			}


			ENDCG
		}

        /*
        GrabPass{}
        // 2パス目の最終出力
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            //#pragma target 3.0

            #include "UnityCG.cginc"
            #include "kodelife.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 grabuv : TEXCOORD0;
                float4 correctgrabuv : TEXCOORD1;
            };

            sampler2D _GrabTexture;
            float4 _GrabTexture_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _GrabTexture);


                //http://light11.hatenadiary.com/entry/2018/06/13/235543
                //proj座標から、スクリーン上の座標を算出する。UnityObjectToClipPos使えばいいけど、生で
                float4 compscreen = o.vertex;
                //DirectXとかOpenglとかの依存をこれでなくす
                compscreen.y *= _ProjectionParams.x;
                //proj座標だから、-wからwまでとる。
                //だから、wで割ると、-1〜1。*0.5+0.5で、0〜1
                //ComputeGrabScreenPos使えばいいけど、生で
                o.grabuv = compscreen.xy/compscreen.z * 0.5 + 0.5;
                o.correctgrabuv = ComputeScreenPos(o.vertex);



                o.correctgrabuv = ComputeScreenPos(o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {


                float4 nowpoint = tex2Dproj(_GrabTexture, i.correctgrabuv);



                float g = nowpoint.g;

                g = length(float2(ddy(g) , ddx(g))) * 100;
                g = abs(g);


                g = g > 0.6 ? 1 : 0;



                //８方向のランダム点から一番ちいさいいろを描画
                float dd = 0.0001;
                int cnt = 0;
                for(int x = -1; x<= 1; x++){ 
                for(int y = -1; y<= 1; y++){
                    float4 neighbor = float4(x,y,0,1) * dd;
                  
                    float4 neighbor_color = tex2D(_GrabTexture, i.correctgrabuv.zw );

                    if(nowpoint.g > neighbor_color.g) cnt=+1;
                }
                }





                float noisePointByFloor = 0;//sin(i.vertex.xy/16 + _Time*100) / 30;


                float4 col = tex2Dproj(_GrabTexture, i.correctgrabuv);

                //float g = col.g;//cnt > 0 ? 1 : 0;


                //float g = cnt < 3 ? 1 : 0;//length(float2(ddx(col.g), ddy(col.g)))*50;

                //g = g > 0.017 ? 1 : 0;

                return fixed4(g,g,g,1);
            }
            ENDCG
        }

        */




	}
}
