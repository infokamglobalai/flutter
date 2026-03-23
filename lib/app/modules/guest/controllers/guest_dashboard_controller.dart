import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class GuestDashboardController extends GetxController {
  // Registration interest form controllers
  final parentNameController = TextEditingController();
  final parentEmailController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final studentNameController = TextEditingController();
  final studentGradeController = TextEditingController();
  final messageController = TextEditingController();
  final registrationFormKey = GlobalKey<FormState>();

  // Partner registration form controllers
  final partnerCompanyNameController = TextEditingController();
  final partnerContactNameController = TextEditingController();
  final partnerEmailController = TextEditingController();
  final partnerPhoneController = TextEditingController();
  final partnerWebsiteController = TextEditingController();
  final partnerDescriptionController = TextEditingController();
  final partnerFormKey = GlobalKey<FormState>();

  // Observable states
  final RxBool isSubmittingRegistration = false.obs;
  final RxBool isSubmittingPartner = false.obs;
  final RxInt selectedVideoIndex = 0.obs;
  final RxString currentVideoUrl = ''.obs;
  YoutubePlayerController? youtubeController;

  // Marketing content
  final RxList<Map<String, dynamic>> marketingVideos = <Map<String, dynamic>>[
    {
      'title': 'Introduction to Physics - Khan Academy',
      'description': 'Learn the fundamentals of physics with expert teachers',
      'thumbnail': 'https://img.youtube.com/vi/OoO5d5P0Jn4/maxresdefault.jpg',
      'url': 'https://www.youtube.com/watch?v=OoO5d5P0Jn4',
      'duration': '10:23',
    },
    {
      'title': 'Mathematics Made Easy',
      'description': 'Master algebra and calculus step by step',
      'thumbnail': 'https://img.youtube.com/vi/fNk_zzaMoSs/maxresdefault.jpg',
      'url': 'https://www.youtube.com/watch?v=fNk_zzaMoSs',
      'duration': '8:45',
    },
    {
      'title': 'Study Tips for Academic Success',
      'description': 'Effective learning strategies from top students',
      'thumbnail': 'https://img.youtube.com/vi/IlU-zDU6aQ0/maxresdefault.jpg',
      'url': 'https://www.youtube.com/watch?v=IlU-zDU6aQ0',
      'duration': '6:30',
    },
  ].obs;

  final RxList<Map<String, dynamic>> marketingDocuments =
      <Map<String, dynamic>>[
        {
          'title': 'Program Brochure 2024',
          'description': 'Complete overview of our courses',
          'icon': Icons.picture_as_pdf,
          'size': '2.5 MB',
          'url': 'https://example.com/brochure.pdf',
        },
        {
          'title': 'Fee Structure',
          'description': 'Detailed pricing and payment plans',
          'icon': Icons.article,
          'size': '1.2 MB',
          'url': 'https://example.com/fees.pdf',
        },
        {
          'title': 'Curriculum Guide',
          'description': 'Board-wise curriculum details',
          'icon': Icons.menu_book,
          'size': '3.8 MB',
          'url': 'https://example.com/curriculum.pdf',
        },
        {
          'title': 'Success Report 2023',
          'description': 'Annual performance statistics',
          'icon': Icons.analytics,
          'size': '1.9 MB',
          'url': 'https://example.com/report.pdf',
        },
      ].obs;

  @override
  void onInit() {
    super.onInit();
    if (marketingVideos.isNotEmpty) {
      currentVideoUrl.value = marketingVideos[0]['url'];
    }
  }

  @override
  void onClose() {
    parentNameController.dispose();
    parentEmailController.dispose();
    parentPhoneController.dispose();
    studentNameController.dispose();
    studentGradeController.dispose();
    messageController.dispose();
    partnerCompanyNameController.dispose();
    partnerContactNameController.dispose();
    partnerEmailController.dispose();
    partnerPhoneController.dispose();
    partnerWebsiteController.dispose();
    partnerDescriptionController.dispose();
    youtubeController?.dispose();
    super.onClose();
  }

  void playVideo(int index) {
    selectedVideoIndex.value = index;
    currentVideoUrl.value = marketingVideos[index]['url'];
  }

  void playVideoInApp(String url, String title) {
    try {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId == null) {
        Get.snackbar(
          'Error',
          'Invalid YouTube URL',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Dispose previous controller if exists
      youtubeController?.dispose();

      // Create new controller with additional flags to prevent OAuth issues
      youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
          forceHD: false,
          hideControls: false,
        ),
      );

      // Show video player dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              youtubeController?.pause();
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Video player
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: YoutubePlayer(
                        controller: youtubeController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                        progressColors: const ProgressBarColors(
                          playedColor: Colors.red,
                          handleColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: true,
      ).then((_) {
        // Dispose controller when dialog closes
        youtubeController?.dispose();
        youtubeController = null;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to play video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> openVideo(String url) async {
    try {
      // Open the video URL in external browser/YouTube app
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open video',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitRegistrationInterest() async {
    if (!registrationFormKey.currentState!.validate()) return;

    try {
      isSubmittingRegistration.value = true;

      // TODO: Replace with actual API call to submit registration interest
      // await _apiClient.post('/guest/registration-interest', {
      //   'parentName': parentNameController.text,
      //   'parentEmail': parentEmailController.text,
      //   'parentPhone': parentPhoneController.text,
      //   'studentName': studentNameController.text,
      //   'studentGrade': studentGradeController.text,
      //   'message': messageController.text,
      // });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Success',
        'Thank you for your interest! Our team will contact you soon.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 4),
      );

      // Clear form
      _clearRegistrationForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit your request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isSubmittingRegistration.value = false;
    }
  }

  Future<void> submitPartnerRequest() async {
    if (!partnerFormKey.currentState!.validate()) return;

    try {
      isSubmittingPartner.value = true;

      // TODO: Replace with actual API call to submit partner request
      // await _apiClient.post('/guest/partner-request', {
      //   'companyName': partnerCompanyNameController.text,
      //   'contactName': partnerContactNameController.text,
      //   'email': partnerEmailController.text,
      //   'phone': partnerPhoneController.text,
      //   'website': partnerWebsiteController.text,
      //   'description': partnerDescriptionController.text,
      // });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Success',
        'Partner request submitted! We will review and contact you soon.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 4),
      );

      // Clear form
      _clearPartnerForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit partner request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isSubmittingPartner.value = false;
    }
  }

  void _clearRegistrationForm() {
    parentNameController.clear();
    parentEmailController.clear();
    parentPhoneController.clear();
    studentNameController.clear();
    studentGradeController.clear();
    messageController.clear();
  }

  void _clearPartnerForm() {
    partnerCompanyNameController.clear();
    partnerContactNameController.clear();
    partnerEmailController.clear();
    partnerPhoneController.clear();
    partnerWebsiteController.clear();
    partnerDescriptionController.clear();
  }

  void openDocument(String url) {
    // TODO: Implement document opening logic
    // You can use url_launcher package or open in WebView
    Get.snackbar(
      'Opening Document',
      'Document viewer will open shortly...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void navigateToLogin() {
    Get.offAllNamed('/login');
  }
}
