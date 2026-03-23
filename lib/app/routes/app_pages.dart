import 'package:get/get.dart';
import 'package:najahapp/app/middlewares/auth_middleware.dart';
import 'package:najahapp/app/modules/auth/bindings/auth_binding.dart';
import 'package:najahapp/app/modules/auth/views/login_view.dart';
import 'package:najahapp/app/modules/splash/splash_module.dart';
import 'package:najahapp/app/modules/onboarding/onboarding_module.dart';
import 'package:najahapp/app/modules/placeholder_modules.dart'
    hide
        ForgotPasswordView,
        NotificationsView,
        NotificationsBinding,
        SettingsView,
        SettingsBinding;
import 'package:najahapp/app/modules/packages/bindings/package_binding.dart';
import 'package:najahapp/app/modules/packages/views/package_selection_view.dart';
import 'package:najahapp/app/modules/packages/views/board_selection_view.dart';
import 'package:najahapp/app/modules/packages/views/subject_selection_view.dart';
import 'package:najahapp/app/modules/packages/views/chapter_selection_view.dart';
import 'package:najahapp/app/modules/packages/views/cart_view.dart';
import 'package:najahapp/app/modules/learning/views/subject_chapter_detail_view.dart';
import 'package:najahapp/app/modules/learning/views/video_player_view.dart'
    as learning_video;
import 'package:najahapp/app/modules/learning/views/chapter_assessment_page.dart';
import 'package:najahapp/app/modules/learning/views/assessment_result_page.dart';
import 'package:najahapp/app/modules/dashboard/views/promotional_video_player_view.dart';
import 'package:najahapp/app/modules/learning/controllers/subject_chapter_controller.dart';
import 'package:najahapp/app/modules/learning/controllers/video_player_controller.dart'
    as learning;
import 'package:najahapp/app/modules/auth/views/email_verification_view.dart';
import 'package:najahapp/app/modules/auth/views/student_registration_view.dart';
import 'package:najahapp/app/modules/auth/views/student_otp_verification_view.dart';
import 'package:najahapp/app/modules/auth/views/forgot_password_view.dart';
import 'package:najahapp/app/modules/dashboard/views/student_profile_view.dart';
import 'package:najahapp/app/modules/dashboard/views/student_progress_view.dart';
import 'package:najahapp/app/modules/learning/views/full_assessment_view.dart';
import 'package:najahapp/app/modules/learning/controllers/full_assessment_controller.dart';
import 'package:najahapp/app/modules/parent/views/parent_dashboard_view.dart';
import 'package:najahapp/app/modules/parent/controllers/parent_dashboard_controller.dart';
import 'package:najahapp/app/modules/parent/views/kid_detailed_progress_view.dart';
import 'package:najahapp/app/modules/parent/controllers/kid_detailed_progress_controller.dart';
import 'package:najahapp/app/modules/mentor/views/mentor_dashboard_view.dart';
import 'package:najahapp/app/modules/mentor/controllers/mentor_dashboard_controller.dart';
import 'package:najahapp/app/modules/guest/views/guest_dashboard_view.dart';
import 'package:najahapp/app/modules/guest/bindings/guest_dashboard_binding.dart';
import 'package:najahapp/app/modules/learning/views/custom_assessment_config_view.dart';
import 'package:najahapp/app/modules/learning/views/custom_assessment_view.dart';
import 'package:najahapp/app/modules/learning/controllers/custom_assessment_controller.dart';
import 'package:najahapp/app/modules/learning/views/downloads_view.dart';
import 'package:najahapp/app/modules/learning/controllers/downloads_controller.dart';
import 'package:najahapp/app/modules/learning/views/qa_view.dart';
import 'package:najahapp/app/modules/learning/controllers/qa_controller.dart';
import 'package:najahapp/app/modules/learning/views/brain_games_view.dart';
import 'package:najahapp/app/modules/learning/controllers/brain_games_controller.dart';
import 'package:najahapp/app/modules/learning/views/mentor_chat_view.dart';
import 'package:najahapp/app/modules/learning/bindings/mentor_chat_binding.dart';
import 'package:najahapp/app/modules/learning/views/student_coaching_view.dart';
import 'package:najahapp/app/modules/learning/bindings/student_coaching_binding.dart';
import 'package:najahapp/app/modules/learning/views/worksheets_view.dart';
import 'package:najahapp/app/modules/learning/bindings/worksheets_binding.dart';
import 'package:najahapp/app/modules/learning/views/watch_history_view.dart';
import 'package:najahapp/app/modules/learning/bindings/watch_history_binding.dart';
import 'package:najahapp/app/modules/support/views/my_tickets_view.dart';
import 'package:najahapp/app/modules/support/views/raise_ticket_view.dart';
import 'package:najahapp/app/modules/support/views/ticket_details_view.dart';
import 'package:najahapp/app/modules/support/bindings/ticket_binding.dart';
import 'package:najahapp/app/modules/notifications/views/notifications_view.dart';
import 'package:najahapp/app/modules/notifications/bindings/notifications_binding.dart';
import 'package:najahapp/app/modules/settings/views/settings_view.dart';
import 'package:najahapp/app/modules/settings/bindings/settings_binding.dart';
import 'package:najahapp/app/modules/payment_history/views/payment_history_view.dart';
import 'package:najahapp/app/modules/payment_history/bindings/payment_history_binding.dart';
import 'package:najahapp/app/modules/subscriptions/views/my_subscriptions_view.dart';
import 'package:najahapp/app/modules/subscriptions/bindings/my_subscriptions_binding.dart';
import 'package:najahapp/app/modules/packages/views/all_packages_view.dart';
import 'package:najahapp/app/modules/packages/bindings/all_packages_binding.dart';
import 'package:najahapp/app/modules/learning/views/self_assessment_list_view.dart';
import 'package:najahapp/app/modules/learning/views/self_assessment_attempt_view.dart';
import 'package:najahapp/app/modules/learning/views/self_assessment_result_view.dart';
import 'package:najahapp/app/modules/learning/controllers/self_assessment_controller.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_PROFILE,
      page: () => const StudentProfileView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_PROGRESS,
      page: () => const StudentProgressView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.BOARDS,
      page: () => const BoardsView(),
      binding: BoardsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.GRADES,
      page: () => const GradesView(),
      binding: GradesBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SUBJECTS,
      page: () => const SubjectsView(),
      binding: SubjectsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CHAPTERS,
      page: () => const ChaptersView(),
      binding: ChaptersBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CHAPTER_DETAIL,
      page: () => const ChapterDetailView(),
      binding: ChapterDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // GetPage(
    //   name: _Paths.VIDEO_PLAYER,
    //   page: () => const VideoPlayerView(),
    //   binding: VideoPlayerBinding(),
    //   // middlewares: [AuthMiddleware()],
    // ),
    GetPage(
      name: _Paths.DOCUMENT_VIEWER,
      page: () => const DocumentViewerView(),
      binding: DocumentViewerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.QUIZ,
      page: () => const QuizView(),
      binding: QuizBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.QUIZ_RESULT,
      page: () => const QuizResultView(),
      binding: QuizResultBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SUBSCRIPTIONS,
      page: () => const SubscriptionsView(),
      binding: SubscriptionsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION_PLANS,
      page: () => const SubscriptionPlansView(),
      binding: SubscriptionPlansBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PROGRESS,
      page: () => const ProgressView(),
      binding: ProgressBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PACKAGE_SELECTION,
      page: () => const PackageSelectionView(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: _Paths.BOARD_SELECTION,
      page: () => const BoardSelectionView(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: _Paths.SUBJECT_SELECTION,
      page: () => const SubjectSelectionView(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: _Paths.CHAPTER_SELECTION,
      page: () => const ChapterSelectionView(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: PackageBinding(),
    ),
    GetPage(
      name: _Paths.SUBJECT_CHAPTER_DETAIL,
      page: () => const SubjectChapterDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SubjectChapterController>(() => SubjectChapterController());
      }),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.VIDEO_PLAYER,
      page: () => const learning_video.VideoPlayerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<learning.VideoPlayerController>(
          () => learning.VideoPlayerController(),
        );
      }),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ASSESSMENT,
      page: () => const ChapterAssessmentPage(),
      // Don't create new controller - use existing one from video player page
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ASSESSMENT_RESULT,
      page: () => const AssessmentResultPage(),
      // Use existing video player controller for assessment results
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PROMOTIONAL_VIDEO_PLAYER,
      page: () => const PromotionalVideoPlayerView(),
    ),
    GetPage(
      name: _Paths.EMAIL_VERIFICATION,
      page: () => const EmailVerificationView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_REGISTER,
      page: () => const StudentRegistrationView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_OTP_VERIFICATION,
      page: () => const StudentOtpVerificationView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.FULL_ASSESSMENT,
      page: () => const FullAssessmentView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FullAssessmentController>(() => FullAssessmentController());
      }),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PARENT_DASHBOARD,
      page: () => const ParentDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ParentDashboardController>(
          () => ParentDashboardController(),
        );
      }),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.KID_DETAILED_PROGRESS,
      page: () => const KidDetailedProgressView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<KidDetailedProgressController>(
          () => KidDetailedProgressController(),
        );
      }),
    ),
    GetPage(
      name: _Paths.MENTOR_DASHBOARD,
      page: () => const MentorDashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MentorDashboardController>(
          () => MentorDashboardController(),
        );
      }),
      // middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.GUEST_DASHBOARD,
      page: () => const GuestDashboardView(),
      binding: GuestDashboardBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOM_ASSESSMENT_CONFIG,
      page: () => const CustomAssessmentConfigView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomAssessmentController>(
          () => CustomAssessmentController(),
        );
      }),
    ),
    GetPage(
      name: _Paths.CUSTOM_ASSESSMENT,
      page: () => const CustomAssessmentView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomAssessmentController>(
          () => CustomAssessmentController(),
        );
      }),
    ),
    GetPage(
      name: _Paths.DOWNLOADS,
      page: () => const DownloadsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DownloadsController>(() => DownloadsController());
      }),
    ),
    GetPage(
      name: _Paths.QA,
      page: () => const QAView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<QAController>(() => QAController());
      }),
    ),
    GetPage(
      name: _Paths.BRAIN_GAMES,
      page: () => const BrainGamesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BrainGamesController>(() => BrainGamesController());
      }),
    ),
    GetPage(
      name: _Paths.MENTOR_CHAT,
      page: () => const MentorChatView(),
      binding: MentorChatBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_COACHING,
      page: () => const StudentCoachingView(),
      binding: StudentCoachingBinding(),
    ),
    GetPage(
      name: _Paths.WORKSHEETS,
      page: () => const WorksheetsView(),
      binding: WorksheetsBinding(),
    ),
    GetPage(
      name: _Paths.WATCH_HISTORY,
      page: () => const WatchHistoryView(),
      binding: WatchHistoryBinding(),
    ),
    GetPage(
      name: _Paths.MY_TICKETS,
      page: () => const MyTicketsView(),
      binding: TicketBinding(),
    ),
    GetPage(
      name: '/ticket-details/:id',
      page: () => const TicketDetailsView(),
      binding: TicketBinding(),
    ),
    GetPage(
      name: _Paths.RAISE_TICKET,
      page: () => const RaiseTicketView(),
      binding: TicketBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_HISTORY,
      page: () => const PaymentHistoryView(),
      binding: PaymentHistoryBinding(),
    ),
    GetPage(
      name: _Paths.MY_SUBSCRIPTIONS,
      page: () => const MySubscriptionsView(),
      binding: MySubscriptionsBinding(),
    ),
    GetPage(
      name: _Paths.ALL_PACKAGES,
      page: () => const AllPackagesView(),
      binding: AllPackagesBinding(),
    ),
    GetPage(
      name: _Paths.SELF_ASSESSMENT_LIST,
      page: () => const SelfAssessmentListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SelfAssessmentController>(
          () => SelfAssessmentController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: _Paths.SELF_ASSESSMENT_ATTEMPT,
      page: () => const SelfAssessmentAttemptView(),
      // Controller already put by list route (fenix: true)
    ),
    GetPage(
      name: _Paths.SELF_ASSESSMENT_RESULT,
      page: () => const SelfAssessmentResultView(),
      // Controller already put by list route (fenix: true)
    ),
  ];
}
