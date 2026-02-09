import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/course_document.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/view/components/course_doc_tile.dart';

/// Demo page showing the Course Details with Documents functionality
/// This page demonstrates how documents appear under each lesson
class CourseDetailDemoScreen extends StatelessWidget {
  CourseDetailDemoScreen({Key? key}) : super(key: key);

  var screenWidth =
      (window.physicalSize.shortestSide / window.devicePixelRatio);

  /// Sample data with documents
  List<LessonModel> get sampleLessons {
    return [
      LessonModel(
        id: 1,
        title: 'Introduction to Flutter',
        course_id: 1,
        description: 'Learn the basics of Flutter development',
        order: 1,
        items: [
          ItemLesson(
            id: 1,
            type: 'lp_lesson',
            title: 'What is Flutter?',
            preview: true,
            duration: '10:00',
            graduation: '',
            status: 'completed',
            locked: false,
          ),
          ItemLesson(
            id: 2,
            type: 'lp_lesson',
            title: 'Setting up the environment',
            preview: false,
            duration: '15:00',
            graduation: '',
            status: '',
            locked: false,
          ),
        ],
        documents: [
          CourseDocument(
            url: 'https://example.com/flutter-intro.pdf',
            title: 'Flutter Introduction.pdf',
            type: DocumentType.pdf,
          ),
          CourseDocument(
            url: 'https://example.com/setup-guide.docx',
            title: 'Setup Guide.docx',
            type: DocumentType.word,
          ),
        ],
      ),
      LessonModel(
        id: 2,
        title: 'Dart Programming Fundamentals',
        course_id: 1,
        description: 'Master Dart programming language',
        order: 2,
        items: [
          ItemLesson(
            id: 3,
            type: 'lp_lesson',
            title: 'Variables and Data Types',
            preview: false,
            duration: '20:00',
            graduation: '',
            status: 'completed',
            locked: false,
          ),
          ItemLesson(
            id: 4,
            type: 'lp_quiz',
            title: 'Dart Basics Quiz',
            preview: false,
            duration: '30:00',
            graduation: 'passed',
            status: 'completed',
            locked: false,
          ),
        ],
        documents: [
          CourseDocument(
            url: 'https://example.com/dart-cheatsheet.pdf',
            title: 'Dart Cheatsheet.pdf',
            type: DocumentType.pdf,
          ),
          CourseDocument(
            url: 'https://example.com/exercises.xlsx',
            title: 'Practice Exercises.xlsx',
            type: DocumentType.excel,
          ),
          CourseDocument(
            url: 'https://example.com/presentation.pptx',
            title: 'Dart Fundamentals.pptx',
            type: DocumentType.powerpoint,
          ),
          CourseDocument(
            url: 'https://flutter.dev',
            title: 'Flutter Official Website',
            type: DocumentType.link,
          ),
        ],
      ),
      LessonModel(
        id: 3,
        title: 'Widget Building',
        course_id: 1,
        description: 'Learn to build beautiful UIs',
        order: 3,
        items: [
          ItemLesson(
            id: 5,
            type: 'lp_lesson',
            title: 'Stateless vs Stateful Widgets',
            preview: false,
            duration: '25:00',
            graduation: '',
            status: '',
            locked: true,
          ),
        ],
        documents: [],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Course Details Demo',
          style: TextStyle(
            fontFamily: 'Poppins-Medium',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey.shade200,
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://via.placeholder.com/375x180',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Complete Flutter Development Bootcamp',
                      style: TextStyle(
                        fontFamily: 'Poppins-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text('4.8 (1,234 reviews)'),
                        SizedBox(width: 16),
                        Text('2,567 students'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lessons Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Course Curriculum',
                      style: TextStyle(
                        fontFamily: 'Poppins-Medium',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${sampleLessons.length} Sections',
                      style: TextStyle(
                        fontFamily: 'Poppins-Regular',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lessons Accordion
              ...sampleLessons.map((lesson) => _buildLessonSection(lesson)),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a lesson section with documents
  Widget _buildLessonSection(LessonModel lesson) {
    bool _showContent = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // Lesson Header
            GestureDetector(
              onTap: () => setState(() => _showContent = !_showContent),
              child: Container(
                width: screenWidth,
                padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _showContent
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: screenWidth - 100,
                          child: Text(
                            lesson.title!,
                            style: const TextStyle(
                              fontFamily: 'Poppins-SemiBold',
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${lesson.items?.length ?? 0} lessons',
                      style: TextStyle(
                        fontFamily: 'Poppins-Regular',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Expanded Content
            if (_showContent)
              Container(
                padding: const EdgeInsets.only(left: 16, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson Items
                    ...lesson.items!.map((item) => _buildLessonItem(item)),
                    
                    // Documents Section
                    if (lesson.documents != null &&
                        lesson.documents!.isNotEmpty)
                      _buildDocumentsSection(lesson.documents!),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build a single lesson item
  Widget _buildLessonItem(ItemLesson item) {
    return GestureDetector(
      onTap: () {
        if (item.status == "completed" || item.locked.toString() == 'false') {
          // Navigate to lesson
        }
      },
      child: Container(
        width: screenWidth,
        padding: const EdgeInsets.fromLTRB(24, 8, 0, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  item.type == 'lp_lesson'
                      ? Icons.book
                      : item.type == 'lp_quiz'
                          ? Icons.quiz
                          : Icons.assignment,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: screenWidth - 120,
                  child: Text(
                    item.title!,
                    style: TextStyle(
                      fontFamily: 'Poppins-Regular',
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if (item.duration != '')
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  item.duration!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the documents section with glassmorphism tiles
  Widget _buildDocumentsSection(List<CourseDocument> documents) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Documents Header
          Row(
            children: [
              Icon(
                Icons.attach_file,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Documents (${documents.length})',
                style: TextStyle(
                  fontFamily: 'Poppins-Medium',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Document Tiles
          ...documents.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CourseDocTile(document: doc),
            ),
          ),
        ],
      ),
    );
  }
}
