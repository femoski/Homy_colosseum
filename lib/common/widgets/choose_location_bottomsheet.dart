import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homy/models/place_model.dart';
import 'package:homy/services/google_place_service.dart';


class ChooseLocatonBottomSheet extends StatefulWidget {
  const ChooseLocatonBottomSheet({super.key});

  @override
  State<ChooseLocatonBottomSheet> createState() => ChooseLocatonBottomSheetState();
}

class ChooseLocatonBottomSheetState extends State<ChooseLocatonBottomSheet> {
  final TextEditingController _searchLocation = TextEditingController();
  Timer? delayTimer;
  List<PlaceModel> searchResults = [];
  bool isLoading = false;
  int previouseLength = 0;
  
  final GooglePlaceService _placeService = GooglePlaceService();

  @override
  void initState() {
    super.initState();

    _searchLocation.addListener(() {
      if (_searchLocation.text.isEmpty) {
        delayTimer?.cancel();
        setState(() {
          searchResults = [];
        });
        return;
      }

      if (delayTimer?.isActive ?? false) delayTimer?.cancel();

      delayTimer = Timer(const Duration(milliseconds: 500), () {
        if (_searchLocation.text.isNotEmpty) {
          if (_searchLocation.text.length != previouseLength) {
            _performSearch();
            previouseLength = _searchLocation.text.length;
          }
        }
      });
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await _placeService.searchPlaces(_searchLocation.text);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        searchResults = [];
      });
      // Handle error appropriately
    }
  }

  @override
  void dispose() {
    _searchLocation.dispose();
    delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchLocation,
              onChanged: (e) {},
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                fillColor: Theme.of(context).primaryColor.withOpacity(0.01),
                filled: true,
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                hintText: 'Search for a location',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
              ),
            ),
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Text('No data found'),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      shrinkWrap: true,
      itemBuilder: (context, int i) {
        return ListTile(
          onTap: () async {
            try {
              final coordinates = await _placeService.getPlaceDetails(
                searchResults[i].placeId,
              );
              
              final placeModel = searchResults[i].copyWith(
                latitude: coordinates.latitude.toString(),
                longitude: coordinates.longitude.toString(),
              );

              Navigator.pop(context, placeModel);
            } catch (e) {
              // Handle error appropriately
            }
          },
          leading: const Icon(Icons.location_city),
          title: Text(searchResults[i].description),
        );
      },
    );
  }
}
