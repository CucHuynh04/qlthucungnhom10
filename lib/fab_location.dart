// lib/fab_location.dart

import 'package:flutter/material.dart';

/// Custom FloatingActionButtonLocation để khớp vị trí với HomePage Profile screen
/// Sử dụng right: -10px và bottom: 1px để khớp với Positioned trong HomePage
class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const CustomFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Tính toán vị trí: right: 0px và bottom: -75px
    // Trong HomePage, nút + được đặt với Positioned(right: -10, bottom: 1)
    // bottom: -75 được tính từ bottom của Stack (từ bottom của body, không tính bottomNavigationBar)
    // HomePage có extendBody: true và bottomNavigationBar (56px)
    // Các màn hình khác (Nhật Ký, Bộ Sưu Tập) được hiển thị trong HomePage body
    // và có Scaffold riêng với extendBody: true nhưng không có bottomNavigationBar
    final double rightOffset = 0.0;
    final double bottomOffset = -75.0;
    
    // Tính toán X: từ bên phải với offset âm để đẩy ra ngoài một chút
    final double fabX = scaffoldGeometry.scaffoldSize.width - 
                        scaffoldGeometry.floatingActionButtonSize.width + 
                        rightOffset;
    
    // Tính toán Y: từ bottom của content (không tính bottomNavigationBar)
    // Với extendBody: true, contentBottom là bottom của body content
    // HomePage có bottomNavigationBar cao 56px, và nút + có bottom: 1 từ bottom của body
    // Các màn hình khác không có bottomNavigationBar, nên contentBottom = scaffoldSize.height
    // Để khớp với HomePage (bottom: 1 từ bottomNavigationBar), cần:
    // - Nếu có bottomNavigationBar: fabY = contentBottom + bottomNavBarHeight - fabHeight - bottomOffset
    // - Nhưng các màn hình này không có bottomNavigationBar, nên:
    // - HomePage: bottom: 1 từ bottomNavBar → thực tế là cách bottom screen: 56 + 1 = 57
    // - Các màn hình: cần cách bottom screen: 1 (vì không có bottomNavBar)
    // Nhưng vì được hiển thị trong HomePage body, cần tính từ viewport của HomePage
    // Đơn giản nhất: tính từ bottom của scaffold, không trừ bottomNavBarHeight
    final double fabY = scaffoldGeometry.contentBottom - 
                       scaffoldGeometry.floatingActionButtonSize.height - 
                       bottomOffset;
    
    return Offset(fabX, fabY);
  }

  @override
  String toString() => 'FloatingActionButtonLocation.customEndFloat';
}

