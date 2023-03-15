package com.example.baidu_map

import android.app.Application
import android.content.Context
import android.os.Bundle
import com.baidu.mapapi.SDKInitializer
import com.baidu.mapapi.base.BmfMapApplication
import com.baidu.mapapi.common.BaiduMapSDKException
import io.flutter.embedding.android.FlutterActivity


class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        SDKInitializer.setAgreePrivacy(applicationContext, true)
        SDKInitializer.initialize(applicationContext)

    }
}
