import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';
import 'package:najahapp/app/data/repositories/data_repository.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Student Registration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                            const SizedBox(height: 20),

                            // Full Name
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => _obscurePassword.value =
                                        !_obscurePassword.value,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'School Name',
                                prefixIcon: const Icon(
                                  Icons.account_balance_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Board',
                                prefixIcon: const Icon(Icons.school_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                              decoration: InputDecoration(
                                labelText: 'Grade',
                                prefixIcon: const Icon(Icons.class_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                decoration: InputDecoration(
                                  labelText: 'State',
                                  prefixIcon: const Icon(
                                    Icons.location_city_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  prefixIcon: const Icon(Icons.place_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                              () => SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _authController.isLoading.value
                                      ? null
                                      : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _authController.isLoading.value
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Register',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
