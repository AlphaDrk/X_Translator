import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../apis/translation_api.dart';
import '../apis/recognition_api.dart';
import 'colors.dart';
import 'theme_provider.dart';

class CameraWidget extends StatefulWidget {
  final CameraDescription camera;

  const CameraWidget({required this.camera, super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController cameraController;
  late Future<void> initCameraFn;
  String? shownText;
  String? errorMessage;
  TranslateLanguage selectedLanguage = TranslateLanguage.english;

  final Map<TranslateLanguage, String> languageNames = {
    for (var lang in TranslateLanguage.values)
      lang: lang.name[0].toUpperCase() + lang.name.substring(1),
  };

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );
    initCameraFn = cameraController.initialize();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          FutureBuilder(
            future: initCameraFn,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraPreview(cameraController),
              );
            },
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.overlayGradient,
            ),
          ),

          // App Title
          Positioned(
            top: 30, // Adjusted for better spacing
            left: 20,
            right: 20,
            child: SafeArea(
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'Photo Translate',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28, // Slightly larger for emphasis
                    shadows: [
                      Shadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Top Bar with Language Selector and Theme Toggle
          Positioned(
            top: 100, // Increased from 50 to create more space below the title
            left: 20,
            right: 20,
            child: SafeArea(
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<TranslateLanguage>(
                            value: selectedLanguage,
                            onChanged: (lang) {
                              if (lang != null) {
                                setState(() => selectedLanguage = lang);
                              }
                            },
                            items: languageNames.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Translation Result
          if (shownText != null)
            Positioned(
              bottom: 100, // Adjusted to accommodate the lower translate button
              left: 20,
              right: 20,
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  child: SizedBox(
                    height: 250, // Increased from 150 to 250 for larger text area
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // Slightly more padding
                        child: Text(
                          shownText!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 22, // Larger font for better readability
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Error Message
          if (errorMessage != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: GlassCard(
                  backgroundColor: AppColors.glassErrorBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

          // Translate Button
          Positioned(
            bottom: 30, // Moved closer to the bottom (from 100 to 30)
            left: MediaQuery.of(context).size.width * 0.5 - 40,
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: () async {
                  try {
                    final image = await cameraController.takePicture();
                    final recognizedText = await RecognitionApi.recognizeText(
                      InputImage.fromFile(File(image.path)),
                    );
                    if (recognizedText == null) return;

                    final translatedText = await TranslationApi.translateText(
                      recognizedText,
                      selectedLanguage,
                    );
                    setState(() {
                      shownText = translatedText;
                      errorMessage = null;
                    });
                  } catch (e) {
                    setState(() {
                      errorMessage = "Error recognizing or translating text";
                    });
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.buttonGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyan.withOpacity(0.5), // Glowing effect
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.translate,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const GlassCard({
    required this.child,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30), // More rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Stronger blur for glass effect
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassBackground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderColor.withOpacity(0.5)), // Softer border
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.3), // Softer shadow
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}