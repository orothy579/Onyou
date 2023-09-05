import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onebody/screens/home/teamMixedList.dart';
import '../../model/teams.dart';

class TeamGridWidget extends StatefulWidget {
  @override
  _TeamGridWidgetState createState() => _TeamGridWidgetState();
}

class _TeamGridWidgetState extends State<TeamGridWidget> {
  late Future<List<Team>> _teamFuture;

  @override
  void initState() {
    super.initState();
    _teamFuture = getTeams();
  }

  Future<List<Team>> getTeams() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('teams').get();
      return snapshot.docs.map((doc) => Team.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception("팀 데이터를 가져오는 데 실패했습니다: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Team>>(
      future: _teamFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        }

        List<Team> teams = snapshot.data!;
        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              Team team = teams[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TeamMixedList(teamRef: FirebaseFirestore.instance.doc('teams/${team.name}')),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Card(
                      shape: CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: 70, // Adjust as needed
                        height: 70, // Adjust as needed
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(team.imgURL),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(team.name, style: TextStyle(fontSize: 12)), // 팀 이름
                  ],
                ),
              );
            },
            childCount: teams.length,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.7,
          ),
        );
      },
    );
  }
}
