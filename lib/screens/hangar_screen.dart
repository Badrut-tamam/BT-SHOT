import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';
import '../components/custom_button.dart';
import '../components/space_background.dart';
import '../components/spaceship_widget.dart';
import '../services/save_service.dart';

class ShipData {
  final int id;
  final String name;
  final Color engineColor;
  final int cost;
  final int baseSpeed;
  final int baseAim;
  final int baseLaser;

  const ShipData({
    required this.id,
    required this.name,
    required this.engineColor,
    required this.cost,
    required this.baseSpeed,
    required this.baseAim,
    required this.baseLaser,
  });
}

const List<ShipData> kShips = [
  ShipData(id: 0, name: 'DEFAULT SHIP', engineColor: Colors.cyanAccent, cost: 0, baseSpeed: 1, baseAim: 1, baseLaser: 1),
  ShipData(id: 1, name: 'FALCON SHIP', engineColor: Colors.greenAccent, cost: 1000, baseSpeed: 2, baseAim: 1, baseLaser: 1),
  ShipData(id: 2, name: 'NEON BLADE', engineColor: Colors.pinkAccent, cost: 2500, baseSpeed: 2, baseAim: 2, baseLaser: 2),
  ShipData(id: 3, name: 'TITAN X', engineColor: Colors.orangeAccent, cost: 5000, baseSpeed: 1, baseAim: 3, baseLaser: 3),
  ShipData(id: 4, name: 'GALAXY HUNTER', engineColor: AppColors.neonPurple, cost: 10000, baseSpeed: 3, baseAim: 3, baseLaser: 3),
];

class HangarScreen extends StatefulWidget {
  const HangarScreen({super.key});

  @override
  State<HangarScreen> createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> {
  int _currentIndex = 0;
  int _coins = 0;
  bool _isUnlocked = false;
  bool _isSelected = false;

  int _speedLevel = 1;
  int _aimLevel = 1;
  int _laserLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _coins = SaveService.getCoins();
    _currentIndex = SaveService.getSelectedShip();
    _updateShipState();
  }

  void _updateShipState() {
    setState(() {
      _isUnlocked = SaveService.isShipUnlocked(_currentIndex);
      _isSelected = SaveService.getSelectedShip() == _currentIndex;
      _speedLevel = SaveService.getShipUpgradeLevel(_currentIndex, 0);
      _aimLevel = SaveService.getShipUpgradeLevel(_currentIndex, 1);
      _laserLevel = SaveService.getShipUpgradeLevel(_currentIndex, 2);
      _coins = SaveService.getCoins();
    });
  }

  void _nextShip() {
    if (_currentIndex < kShips.length - 1) {
      setState(() { _currentIndex++; });
      _updateShipState();
    }
  }

  void _prevShip() {
    if (_currentIndex > 0) {
      setState(() { _currentIndex--; });
      _updateShipState();
    }
  }

  Future<void> _buyShip() async {
    final ship = kShips[_currentIndex];
    if (_coins >= ship.cost) {
      await SaveService.spendCoins(ship.cost);
      await SaveService.unlockShip(ship.id);
      await SaveService.setSelectedShip(ship.id);
      _updateShipState();
    }
  }

  Future<void> _selectShip() async {
    await SaveService.setSelectedShip(kShips[_currentIndex].id);
    _updateShipState();
  }

  Future<void> _upgradeStat(int type) async {
    int currentLevel = SaveService.getShipUpgradeLevel(_currentIndex, type);
    if (currentLevel >= 5) return;
    
    int cost = 500 * currentLevel;
    if (_coins >= cost) {
      await SaveService.spendCoins(cost);
      await SaveService.setShipUpgradeLevel(_currentIndex, type, currentLevel + 1);
      _updateShipState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ship = kShips[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const RepaintBoundary(child: SpaceBackground()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ship Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: _currentIndex > 0 ? _prevShip : null,
                          ),
                          
                          // Ship Preview
                          Column(
                            children: [
                              Text(
                                ship.name,
                                style: GoogleFonts.outfit(
                                  color: ship.engineColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: SpaceshipWidget(angle: 0, engineColor: ship.engineColor, shipId: ship.id),
                                ),
                              ),
                            ],
                          ),
                          
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                            onPressed: _currentIndex < kShips.length - 1 ? _nextShip : null,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Upgrades Section
                      if (_isUnlocked)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                _buildUpgradeRow('FIRE RATE', _speedLevel, 0),
                                const SizedBox(height: 12),
                                _buildUpgradeRow('AIM ASSIST', _aimLevel, 1),
                                const SizedBox(height: 12),
                                _buildUpgradeRow('LASER DMG', _laserLevel, 2),
                              ],
                            ),
                          ),
                        ),
                        
                      const SizedBox(height: 30),
                      
                      // Action Button
                      if (!_isUnlocked)
                        CustomButton(
                          text: 'BUY FOR ${ship.cost} C',
                          icon: Icons.shopping_cart,
                          onPressed: _coins >= ship.cost ? _buyShip : () {},
                          isSecondary: _coins < ship.cost,
                        )
                      else if (!_isSelected)
                        CustomButton(
                          text: 'SELECT SHIP',
                          icon: Icons.check_circle_outline,
                          onPressed: _selectShip,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neonBlue),
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.neonBlue.withOpacity(0.2),
                          ),
                          child: Text(
                            'CURRENTLY SELECTED',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'HANGAR',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_coins',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeRow(String label, int level, int type) {
    int cost = 500 * level;
    bool isMax = level >= 5;
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: 15,
                height: 8,
                decoration: BoxDecoration(
                  color: index < level ? AppColors.neonBlue : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: index < level ? [BoxShadow(color: AppColors.neonBlue, blurRadius: 4)] : [],
                ),
              );
            }),
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: isMax ? null : () => _upgradeStat(type),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isMax ? Colors.transparent : ( _coins >= cost ? AppColors.neonPurple : Colors.grey.withOpacity(0.3) ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isMax ? Colors.grey : Colors.transparent),
              ),
              child: Text(
                isMax ? 'MAX' : '$cost C',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
