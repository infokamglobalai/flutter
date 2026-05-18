import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/utils/ui_utils.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';
import 'package:najahapp/app/data/repositories/data_repository.dart';
import 'dart:math' as math;

class StudentRegistrationView extends StatefulWidget {
  const StudentRegistrationView({super.key});

  @override
  State<StudentRegistrationView> createState() =>
      _StudentRegistrationViewState();
}

class _StudentRegistrationViewState extends State<StudentRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();
  final _dataRepository = DataRepository();

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolNameController = TextEditingController();

  // Observable lists
  final RxList<BoardModel> _boards = <BoardModel>[].obs;
  final RxList<GradeModel> _grades = <GradeModel>[].obs;
  final RxList<String> _states = <String>[].obs;
  final RxList<String> _cities = <String>[].obs;
  final RxBool _isLoadingData = true.obs;
  final RxBool _isLoadingStates = true.obs;
  final RxBool _isLoadingCities = false.obs;
  final RxBool _obscurePassword = true.obs;

  // Selected values
  String? _selectedBoard;
  String? _selectedGrade;
  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadStates();
  }

  Future<void> _loadData() async {
    try {
      _isLoadingData.value = true;
      final boards = await _dataRepository.getBoards();
      final grades = await _dataRepository.getGrades();
      _boards.value = boards;
      _grades.value = grades;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load boards and grades: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoadingData.value = false;
    }
  }

  Future<void> _loadStates() async {
    try {
      _isLoadingStates.value = true;

      // Using hardcoded states list as the API is not working reliably
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate loading

      _states.value = [
        'Andhra Pradesh',
        'Arunachal Pradesh',
        'Assam',
        'Bihar',
        'Chhattisgarh',
        'Goa',
        'Gujarat',
        'Haryana',
        'Himachal Pradesh',
        'Jharkhand',
        'Karnataka',
        'Kerala',
        'Madhya Pradesh',
        'Maharashtra',
        'Manipur',
        'Meghalaya',
        'Mizoram',
        'Nagaland',
        'Odisha',
        'Punjab',
        'Rajasthan',
        'Sikkim',
        'Tamil Nadu',
        'Telangana',
        'Tripura',
        'Uttar Pradesh',
        'Uttarakhand',
        'West Bengal',
        'Andaman and Nicobar Islands',
        'Chandigarh',
        'Dadra and Nagar Haveli and Daman and Diu',
        'Delhi',
        'Jammu and Kashmir',
        'Ladakh',
        'Lakshadweep',
        'Puducherry',
      ];

      print('States loaded: ${_states.length}');
    } catch (e) {
      print('Exception loading states: $e');
      Get.snackbar(
        'Error',
        'Failed to load states: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isLoadingStates.value = false;
    }
  }

  Future<void> _loadCities(String state) async {
    try {
      _isLoadingCities.value = true;
      _cities.clear();
      _selectedCity = null;

      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Simulate loading

      // Hardcoded major cities for each state
      final stateCitiesMap = {
        'Andhra Pradesh': [
          'Visakhapatnam',
          'Vijayawada',
          'Guntur',
          'Nellore',
          'Kurnool',
          'Kakinada',
          'Rajahmundry',
          'Tirupati',
          'Kadapa',
          'Anantapur',
        ],
        'Arunachal Pradesh': [
          'Itanagar',
          'Naharlagun',
          'Pasighat',
          'Tawang',
          'Ziro',
          'Bomdila',
          'Tezu',
          'Seppa',
          'Changlang',
          'Along',
        ],
        'Assam': [
          'Guwahati',
          'Silchar',
          'Dibrugarh',
          'Jorhat',
          'Nagaon',
          'Tinsukia',
          'Tezpur',
          'Bongaigaon',
          'Diphu',
          'Dhubri',
        ],
        'Bihar': [
          'Patna',
          'Gaya',
          'Bhagalpur',
          'Muzaffarpur',
          'Purnia',
          'Darbhanga',
          'Bihar Sharif',
          'Arrah',
          'Begusarai',
          'Katihar',
        ],
        'Chhattisgarh': [
          'Raipur',
          'Bhilai',
          'Bilaspur',
          'Korba',
          'Durg',
          'Rajnandgaon',
          'Jagdalpur',
          'Raigarh',
          'Ambikapur',
          'Mahasamund',
        ],
        'Goa': [
          'Panaji',
          'Margao',
          'Vasco da Gama',
          'Mapusa',
          'Ponda',
          'Bicholim',
          'Curchorem',
          'Sanquelim',
          'Cuncolim',
          'Quepem',
        ],
        'Gujarat': [
          'Ahmedabad',
          'Surat',
          'Vadodara',
          'Rajkot',
          'Bhavnagar',
          'Jamnagar',
          'Junagadh',
          'Gandhinagar',
          'Nadiad',
          'Anand',
        ],
        'Haryana': [
          'Faridabad',
          'Gurgaon',
          'Panipat',
          'Ambala',
          'Yamunanagar',
          'Rohtak',
          'Hisar',
          'Karnal',
          'Sonipat',
          'Panchkula',
        ],
        'Himachal Pradesh': [
          'Shimla',
          'Mandi',
          'Solan',
          'Nahan',
          'Sundernagar',
          'Palampur',
          'Kullu',
          'Hamirpur',
          'Una',
          'Dharamshala',
        ],
        'Jharkhand': [
          'Ranchi',
          'Jamshedpur',
          'Dhanbad',
          'Bokaro',
          'Deoghar',
          'Phusro',
          'Hazaribagh',
          'Giridih',
          'Ramgarh',
          'Medininagar',
        ],
        'Karnataka': [
          'Bangalore',
          'Mysore',
          'Hubli',
          'Mangalore',
          'Belgaum',
          'Gulbarga',
          'Davanagere',
          'Bellary',
          'Bijapur',
          'Shimoga',
        ],
        'Kerala': [
          'Thiruvananthapuram',
          'Kochi',
          'Kozhikode',
          'Kollam',
          'Thrissur',
          'Palakkad',
          'Alappuzha',
          'Malappuram',
          'Kannur',
          'Kottayam',
        ],
        'Madhya Pradesh': [
          'Indore',
          'Bhopal',
          'Jabalpur',
          'Gwalior',
          'Ujjain',
          'Sagar',
          'Dewas',
          'Satna',
          'Ratlam',
          'Rewa',
        ],
        'Maharashtra': [
          'Mumbai',
          'Pune',
          'Nagpur',
          'Thane',
          'Nashik',
          'Aurangabad',
          'Solapur',
          'Amravati',
          'Kolhapur',
          'Nanded',
        ],
        'Manipur': [
          'Imphal',
          'Thoubal',
          'Bishnupur',
          'Churachandpur',
          'Kakching',
          'Ukhrul',
          'Senapati',
          'Tamenglong',
          'Jiribam',
          'Moirang',
        ],
        'Meghalaya': [
          'Shillong',
          'Tura',
          'Nongstoin',
          'Jowai',
          'Baghmara',
          'Williamnagar',
          'Nongpoh',
          'Mairang',
          'Resubelpara',
          'Khliehriat',
        ],
        'Mizoram': [
          'Aizawl',
          'Lunglei',
          'Champhai',
          'Serchhip',
          'Kolasib',
          'Lawngtlai',
          'Saiha',
          'Mamit',
          'Khawzawl',
          'Saitual',
        ],
        'Nagaland': [
          'Kohima',
          'Dimapur',
          'Mokokchung',
          'Tuensang',
          'Wokha',
          'Zunheboto',
          'Phek',
          'Mon',
          'Longleng',
          'Kiphire',
        ],
        'Odisha': [
          'Bhubaneswar',
          'Cuttack',
          'Rourkela',
          'Berhampur',
          'Sambalpur',
          'Puri',
          'Balasore',
          'Bhadrak',
          'Baripada',
          'Jeypore',
        ],
        'Punjab': [
          'Ludhiana',
          'Amritsar',
          'Jalandhar',
          'Patiala',
          'Bathinda',
          'Mohali',
          'Hoshiarpur',
          'Batala',
          'Pathankot',
          'Moga',
        ],
        'Rajasthan': [
          'Jaipur',
          'Jodhpur',
          'Kota',
          'Bikaner',
          'Ajmer',
          'Udaipur',
          'Bhilwara',
          'Alwar',
          'Bharatpur',
          'Sikar',
        ],
        'Sikkim': [
          'Gangtok',
          'Namchi',
          'Gyalshing',
          'Mangan',
          'Jorethang',
          'Rangpo',
          'Singtam',
          'Ravangla',
          'Pelling',
          'Yuksom',
        ],
        'Tamil Nadu': [
          'Chennai',
          'Coimbatore',
          'Madurai',
          'Tiruchirappalli',
          'Salem',
          'Tirunelveli',
          'Tiruppur',
          'Erode',
          'Vellore',
          'Thoothukudi',
        ],
        'Telangana': [
          'Hyderabad',
          'Warangal',
          'Nizamabad',
          'Khammam',
          'Karimnagar',
          'Ramagundam',
          'Mahbubnagar',
          'Nalgonda',
          'Adilabad',
          'Suryapet',
        ],
        'Tripura': [
          'Agartala',
          'Udaipur',
          'Dharmanagar',
          'Kailashahar',
          'Ambassa',
          'Belonia',
          'Khowai',
          'Sabroom',
          'Sonamura',
          'Teliamura',
        ],
        'Uttar Pradesh': [
          'Lucknow',
          'Kanpur',
          'Ghaziabad',
          'Agra',
          'Varanasi',
          'Meerut',
          'Allahabad',
          'Bareilly',
          'Aligarh',
          'Moradabad',
        ],
        'Uttarakhand': [
          'Dehradun',
          'Haridwar',
          'Roorkee',
          'Haldwani',
          'Rudrapur',
          'Kashipur',
          'Rishikesh',
          'Pithoragarh',
          'Ramnagar',
          'Nainital',
        ],
        'West Bengal': [
          'Kolkata',
          'Howrah',
          'Durgapur',
          'Asansol',
          'Siliguri',
          'Bardhaman',
          'Malda',
          'Baharampur',
          'Habra',
          'Kharagpur',
        ],
        'Andaman and Nicobar Islands': [
          'Port Blair',
          'Diglipur',
          'Rangat',
          'Mayabunder',
          'Car Nicobar',
          'Nancowry',
          'Campbell Bay',
          'Hut Bay',
        ],
        'Chandigarh': ['Chandigarh'],
        'Dadra and Nagar Haveli and Daman and Diu': [
          'Daman',
          'Diu',
          'Silvassa',
        ],
        'Delhi': [
          'New Delhi',
          'North Delhi',
          'South Delhi',
          'East Delhi',
          'West Delhi',
          'Central Delhi',
          'North East Delhi',
          'North West Delhi',
          'South East Delhi',
          'South West Delhi',
        ],
        'Jammu and Kashmir': [
          'Srinagar',
          'Jammu',
          'Anantnag',
          'Baramulla',
          'Sopore',
          'Kathua',
          'Udhampur',
          'Rajouri',
          'Poonch',
          'Kupwara',
        ],
        'Ladakh': [
          'Leh',
          'Kargil',
          'Nubra',
          'Zanskar',
          'Drass',
          'Nyoma',
          'Khalsi',
          'Panamik',
        ],
        'Lakshadweep': [
          'Kavaratti',
          'Agatti',
          'Amini',
          'Andrott',
          'Minicoy',
          'Kalpeni',
          'Kadmat',
          'Kiltan',
        ],
        'Puducherry': ['Puducherry', 'Karaikal', 'Mahe', 'Yanam'],
      };

      _cities.value = stateCitiesMap[state] ?? [];
      _cities.sort();

      print('Cities loaded for $state: ${_cities.length}');

      if (_cities.isEmpty) {
        _cities.value = ['Other'];
      }
    } catch (e) {
      print('Exception loading cities: $e');
      _cities.value = ['Other'];
    } finally {
      _isLoadingCities.value = false;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBoard == null || _selectedGrade == null) {
      Get.snackbar(
        'Error',
        'Please select board and grade',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_selectedState == null || _selectedCity == null) {
      Get.snackbar(
        'Error',
        'Please select state and city',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await _authController.registerStudent(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      schoolName: _schoolNameController.text.trim(),
      board: _selectedBoard!,
      grade: _selectedGrade!,
      state: _selectedState!,
      city: _selectedCity!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: UIUtils.meshGradientDecoration(
              colors: [
                AppTheme.primaryColor,
                const Color(0xFF1E293B),
                const Color(0xFF0F172A),
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          const Positioned(
            top: -100,
            right: -50,
            child: _AnimatedGlowBlob(color: Colors.white, size: 300),
          ),
          const Positioned(
            bottom: 100,
            left: -80,
            child: _AnimatedGlowBlob(color: Colors.cyanAccent, size: 350),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 20, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.back();
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              // Form
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() {
                    if (_isLoadingData.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'STUDENT REGISTRATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF64748B),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Full Name
                            TextFormField(
                              controller: _fullNameController,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              decoration: UIUtils.glassInputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              decoration: UIUtils.glassInputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!GetUtils.isEmail(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            Obx(
                              () => TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword.value,
                                decoration: UIUtils.glassInputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword.value
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 20,
                                      color: const Color(0xFF64748B),
                                    ),
                                    onPressed: () => _obscurePassword.value =
                                        !_obscurePassword.value,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Phone
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: UIUtils.glassInputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icons.phone_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length != 10) {
                                  return 'Phone number must be exactly 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // School Name
                            TextFormField(
                              controller: _schoolNameController,
                              decoration: UIUtils.glassInputDecoration(
                                labelText: 'School Name',
                                prefixIcon: Icons.account_balance_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your school name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Board Dropdown
                            DropdownButtonFormField<String>(
                              decoration: UIUtils.glassInputDecoration(
                                labelText: 'Board',
                                prefixIcon: Icons.school_outlined,
                              ),
                              value: _selectedBoard,
                              items: _boards
                                  .map(
                                    (board) => DropdownMenuItem(
                                      value: board.id,
                                      child: Text(board.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedBoard = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select your board';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Grade Dropdown
                            DropdownButtonFormField<String>(
                              decoration: UIUtils.glassInputDecoration(
                                labelText: 'Grade',
                                prefixIcon: Icons.grade_outlined,
                              ),
                              value: _selectedGrade,
                              items: _grades
                                  .map(
                                    (grade) => DropdownMenuItem(
                                      value: grade.id,
                                      child: Text(grade.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedGrade = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select your grade';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // State Dropdown
                            Obx(
                              () => DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: UIUtils.glassInputDecoration(
                                  labelText: 'State',
                                  prefixIcon: Icons.location_on_outlined,
                                ),
                                hint: _isLoadingStates.value
                                    ? const Text('Loading...')
                                    : _states.isEmpty
                                    ? const Text('No states')
                                    : null,
                                value: _selectedState,
                                items: _states.isEmpty
                                    ? null
                                    : _states
                                          .toList()
                                          .map(
                                            (state) => DropdownMenuItem(
                                              value: state,
                                              child: Text(state),
                                            ),
                                          )
                                          .toList(),
                                onChanged:
                                    _isLoadingStates.value || _states.isEmpty
                                    ? null
                                    : (value) {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _selectedState = value;
                                          _selectedCity = null;
                                        });
                                        if (value != null) {
                                          _loadCities(value);
                                        }
                                      },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select your state';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // City Dropdown
                            Obx(
                              () => DropdownButtonFormField<String>(
                                isExpanded: true,
                                decoration: UIUtils.glassInputDecoration(
                                  labelText: 'City',
                                  prefixIcon: Icons.location_city_outlined,
                                ),
                                hint: _isLoadingCities.value
                                    ? const Text('Loading...')
                                    : _selectedState == null
                                    ? const Text('Select state first')
                                    : _cities.isEmpty
                                    ? const Text('No cities')
                                    : null,
                                value: _selectedCity,
                                items: _cities.isEmpty
                                    ? null
                                    : _cities
                                          .toList()
                                          .map(
                                            (city) => DropdownMenuItem(
                                              value: city,
                                              child: Text(city),
                                            ),
                                          )
                                          .toList(),
                                onChanged:
                                    _isLoadingCities.value ||
                                        _selectedState == null ||
                                        _cities.isEmpty
                                    ? null
                                    : (value) {
                                        HapticFeedback.selectionClick();
                                        setState(() => _selectedCity = value);
                                      },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select your city';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Register Button
                            Obx(
                              () => Container(
                                decoration: UIUtils.glossyDecoration(
                                  baseColor: AppTheme.primaryColor,
                                  borderRadius: 16,
                                ),
                                child: ElevatedButton(
                                  onPressed: _authController.isLoading.value
                                      ? null
                                      : () {
                                          HapticFeedback.mediumImpact();
                                          _handleRegister();
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _authController.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Create My Account',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account?'),
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

class _AnimatedGlowBlob extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedGlowBlob({required this.color, required this.size});

  @override
  State<_AnimatedGlowBlob> createState() => _AnimatedGlowBlobState();
}

class _AnimatedGlowBlobState extends State<_AnimatedGlowBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(0.12),
                  widget.color.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
