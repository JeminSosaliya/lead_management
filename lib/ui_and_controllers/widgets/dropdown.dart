import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lead_management/core/constant/app_color.dart';
import 'package:lead_management/core/constant/app_const.dart';
import 'package:lead_management/ui_and_controllers/widgets/want_text.dart';


class SearchableCSCDropdown extends StatefulWidget {
  final String? title;
  final List<String> items;
  final Function(String) onChanged;
  final String hintText;
  final IconData iconData1;
  final IconData iconData2;
  final TextInputType? keyboardType;
  final bool showError;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final FocusNode? nextFocusNode;


  const SearchableCSCDropdown({
    Key? key,
    this.title,
    required this.items,
    required this.onChanged,
    this.hintText = "Select an option",
    required this.iconData1,
    required this.iconData2,
    this.keyboardType,
    this.showError = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.nextFocusNode,
  }) : super(key: key);

  @override
  _SearchableCSCDropdownState createState() => _SearchableCSCDropdownState();
}

class _SearchableCSCDropdownState extends State<SearchableCSCDropdown> {
  TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  List<String> _filteredItems = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;

    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _filteredItems = widget.items;
          _isDropdownOpen = true;
        });
      } else {
        setState(() {
          _isDropdownOpen = false;
        });
      }
    });
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });

    widget.onChanged(query);
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          WantText(
            text: widget.title!,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w600,
          ),
        if (widget.title != null)
          SizedBox(height: height * 0.01),

        SizedBox(
          height: height * 0.062,
          child: TextFormField(
            keyboardType: widget.keyboardType,
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: (_) {
              if (widget.nextFocusNode != null) {
                widget.nextFocusNode!.requestFocus();
              } else {
                _focusNode.unfocus();
              }
            },
            style: GoogleFonts.roboto(
              fontSize: width * 0.038,
              color: colorBlack,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.roboto(
                color: colorGreyText,
                fontSize: width * 0.035,
                fontWeight: FontWeight.w400,
                height: 1.75,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
                borderSide:
                BorderSide(color: colorGreyTextFieldBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
                borderSide:
                BorderSide(color: colorGreyTextFieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
                borderSide:
                BorderSide(color: colorGreyTextFieldBorder),
              ),
              errorText: widget.showError ? '' : null,
              errorStyle: const TextStyle(height: 0, fontSize: 0), // ye add karo

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(width * 0.0266)),
                borderSide: BorderSide(color: colorRedError, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(width * 0.0266)),
                borderSide: BorderSide(color: colorRedError, width: 1),
              ),
              suffixIcon: GestureDetector(
                onTap: _toggleDropdown,
                child: _isDropdownOpen == false
                    ? Icon(
                  widget.iconData1,
                  color: colorGreyText,
                  size: width * 0.065,
                )
                    : Icon(
                  widget.iconData2,
                  color: colorGreyTextFieldBorder,
                  size: width * 0.065,
                ),
              ),
            ),
            onChanged: _filterItems,
            onTap: () {
              setState(() {
                _filteredItems =
                    widget.items; // Reset filtered list when tapped
                _isDropdownOpen = true;
              });
            },
          ),
        ),

        if (_isDropdownOpen && _filteredItems.isNotEmpty)
          Container(
            height: _filteredItems.length >= 4
                ? height * 0.25
                : _filteredItems.length >= 3
                ? height * 0.185
                : _filteredItems.length >= 2
                ? height * 0.125
                : height * 0.065,
            margin: EdgeInsets.only(top: height * 0.01),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.0266),
              color: colorWhite,
              border: Border.all(color: colorGreyText),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.text = _filteredItems[index];
                        _isDropdownOpen = false; // Close dropdown on select
                        _focusNode.unfocus(); // Close keyboard
                      });
                      widget.onChanged(_filteredItems[index]);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: width * 0.028, horizontal: width * 0.035),
                      child: WantText(
                        text: _filteredItems[index],
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w400,
                        textColor: colorBlack,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}