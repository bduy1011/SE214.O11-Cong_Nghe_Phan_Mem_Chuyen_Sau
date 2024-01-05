import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/community.dart';
import 'package:assist_health/ui/user_screens/question_detail.dart';

class PublicQuestionsScreen extends StatefulWidget {
  const PublicQuestionsScreen({Key? key}) : super(key: key);

  @override
  _PublicQuestionsScreenState createState() => _PublicQuestionsScreenState();
}

class _PublicQuestionsScreenState extends State<PublicQuestionsScreen> {
  List<bool> isLikedList = [];
  List<String> selectedFilterCategories = [];
  final List<String> categories = [
    'Health', 'Fitness', 'Nutrition', 'Mental Health', 'Other'
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Cộng đồng hỏi đáp'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              List<String>? result = await _showCategoryFilterDialog(context);

              if (result != null) {
                setState(() {
                  selectedFilterCategories = result;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('public_questions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<Question> questions = [];
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          for (var document in documents) {
            final List<dynamic> categories = document['categories'];
            final question = Question(
              id: document.id,
              gender: document['gender'],
              age: document['age'],
              title: document['title'],
              content: document['content'],
              categories: categories.cast<String>().toList(),
              answerCount: 0,
            );

            questions.add(question);
            isLikedList.add(false);
          }

          final filteredQuestions = questions
              .where((question) =>
                  selectedFilterCategories.isEmpty ||
                  question.categories.any((category) => selectedFilterCategories.contains(category)))
              .toList();

          return ListView.builder(
            itemCount: filteredQuestions.length,
            itemBuilder: (context, index) {
              bool isLiked = isLikedList.length > index ? isLikedList[index] : false;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionDetailScreen(
                        question: filteredQuestions[index],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        '${filteredQuestions[index].gender}, ${filteredQuestions[index].age} tuổi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chủ đề: ${filteredQuestions[index].title}',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nội dung câu hỏi: ${filteredQuestions[index].content}',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.chat,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isLikedList[index] = !isLikedList[index];
                              });
                            },
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        backgroundColor: Themes.selectedClr,
        label: const Text(
          'Đặt câu hỏi',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CommunityScreen(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<List<String>?> _showCategoryFilterDialog(BuildContext context) async {
    List<String> selectedCategoriesCopy = List.from(selectedFilterCategories);

    return await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn chuyên khoa thẩm mĩ'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: categories.map((category) {
                  final isSelected = selectedCategoriesCopy.contains(category);
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Text(category),
                        if (isSelected) const Icon(Icons.check),
                      ],
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          if (value) {
                            selectedCategoriesCopy.add(category);
                          } else {
                            selectedCategoriesCopy.remove(category);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedCategoriesCopy);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
