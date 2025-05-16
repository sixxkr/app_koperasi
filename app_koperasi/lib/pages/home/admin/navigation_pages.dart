import 'package:app_koperasi/pages/home/admin/admin_home.dart';
import 'package:app_koperasi/pages/home/admin/anggota.dart';
import 'package:app_koperasi/pages/home/admin/barang.dart';
import 'package:app_koperasi/pages/home/admin/profile.dart';
import 'package:app_koperasi/pages/home/admin/transaksi.dart';
import 'package:app_koperasi/pages/home/admin/laporan_penjualan.dart';
import 'package:app_koperasi/services/auth_service.dart';
import 'package:app_koperasi/styles/color.dart';
import 'package:app_koperasi/styles/font.dart';
import 'package:flutter/material.dart';

class AdminNavigationMenu extends StatefulWidget {
  const AdminNavigationMenu({Key? key}) : super(key: key);
  static const nameRoute = '/main';

  @override
  State<AdminNavigationMenu> createState() => _MainPageState();
}

class _MainPageState extends State<AdminNavigationMenu> {
  int _selectedIndex = 0;
  int? userId;
  final AuthService _authService = AuthService();

  void loadUserId() async {
    final id = await AuthService.getUserId();
    if (id != null) {
      setState(() {
        userId = id;
      });
    }
  }

  List<Widget> get pages {
    return [
      AdminHome(),
      TransaksiAdmin(),
      LaporanPenjualanPage(),
      BarangAdmin(),
      ListAnggotaPage(),
      ProfileAdmin(userId: userId ?? 0)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      loadUserId();
    });
  }

  @override
  void initState() {
    super.initState();
    _authService.checkSession(1, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: _customBottomNav(),
    );
  }

  Widget _customBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
          color: bgColor1,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              15,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: txtshadowheart,
              blurRadius: 10,
            )
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            15,
          ),
        ),
        child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedLabelStyle: txtshadow,
            unselectedLabelStyle: txtshadow,
            selectedItemColor: bgColor1,
            unselectedItemColor: txtshadowlogin,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color: _selectedIndex == 0 ? bgColor1 : txtshadowlogin,
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.receipt,
                    color: _selectedIndex == 1 ? bgColor1 : txtshadowlogin,
                  ),
                  label: 'Transaksi'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.receipt_long,
                    color: _selectedIndex == 2 ? bgColor1 : txtshadowlogin,
                  ),
                  label: 'Laporan Penjualan'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.inventory,
                    color: _selectedIndex == 3 ? bgColor1 : txtshadowlogin,
                  ),
                  label: 'Barang'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.groups,
                    color: _selectedIndex == 4 ? bgColor1 : txtshadowlogin,
                  ),
                  label: 'Anggota'),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.account_circle,
                    color: _selectedIndex == 5 ? bgColor1 : txtshadowlogin,
                  ),
                  label: 'Profile'),
            ]),
      ),
    );
  }
}
