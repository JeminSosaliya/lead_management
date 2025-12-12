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
  final ValueChanged<String>? onFieldSubmitted;


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
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  _SearchableCSCDropdownState createState() => _SearchableCSCDropdownState();
}

class _SearchableCSCDropdownState extends State<SearchableCSCDropdown> {
  TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  List<String> _filteredItems = [];
  bool _isDropdownOpen = false;
  String? _lastValidValue;

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
        _validateAndReset();
        setState(() {
          _isDropdownOpen = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _validateAndReset() {
    final currentText = _controller.text.trim();
    if (currentText.isEmpty) {
      _lastValidValue = null;
      widget.onChanged('');
      return;
    }

    final isValid = widget.items.any(
      (item) => item.toLowerCase() == currentText.toLowerCase()
    );
    
    if (!isValid) {
      _controller.text = _lastValidValue ?? '';
      widget.onChanged(_lastValidValue ?? '');
    } else {
      _lastValidValue = currentText;
    }
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

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _lastValidValue = null;
      widget.onChanged('');
    } else {
      final exactMatch = widget.items.any(
        (item) => item.toLowerCase() == trimmedQuery.toLowerCase()
      );
      if (exactMatch) {
        _lastValidValue = trimmedQuery;
        widget.onChanged(trimmedQuery);
      }
    }
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
            textColor: Colors.black87,
          ),
        if (widget.title != null) SizedBox(height: height * 0.01),

        SizedBox(
          height: height * 0.068,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: widget.textInputAction,
            cursorColor: colorMainTheme,
            style: GoogleFonts.roboto(
              fontSize: width * 0.04,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.roboto(
                color: Colors.black45,
                fontSize: width * 0.036,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.96),
              contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.018),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.black26, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.black26, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorMainTheme, width: 1.2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorRedError, width: 1),
              ),
              suffixIcon: GestureDetector(
                onTap: _toggleDropdown,
                child: Icon(
                  _isDropdownOpen ? widget.iconData2 : widget.iconData1,
                  color: _isDropdownOpen ? colorMainTheme : Colors.black54,
                  size: width * 0.07,
                ),
              ),
            ),
            onChanged: _filterItems,
            onFieldSubmitted: (_) {
              // Validate before submitting
              _validateAndReset();
              if (widget.nextFocusNode != null) {
                widget.nextFocusNode!.requestFocus();
              } else {
                _focusNode.unfocus();
              }
              widget.onFieldSubmitted?.call(_controller.text);
            },
            onTap: () {
              setState(() {
                _filteredItems = widget.items;
                _isDropdownOpen = true;
              });
            },
          ),
        ),

        // Dropdown List
        if (_isDropdownOpen)
          Container(
            margin: EdgeInsets.only(top: 6),
            constraints: BoxConstraints(maxHeight: height * 0.3),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: _filteredItems.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            final selectedValue = _filteredItems[index];
                            setState(() {
                              _controller.text = selectedValue;
                              _lastValidValue = selectedValue;
                              _isDropdownOpen = false;
                              _focusNode.unfocus();
                            });
                            widget.onChanged(selectedValue);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            child: Text(
                              _filteredItems[index],
                              style: GoogleFonts.roboto(
                                fontSize: width * 0.04,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : _controller.text.trim().isNotEmpty
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Center(
                          child: Text(
                            'No result found',
                            style: GoogleFonts.roboto(
                              fontSize: width * 0.038,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                final selectedValue = widget.items[index];
                                setState(() {
                                  _controller.text = selectedValue;
                                  _lastValidValue = selectedValue;
                                  _isDropdownOpen = false;
                                  _focusNode.unfocus();
                                });
                                widget.onChanged(selectedValue);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                child: Text(
                                  widget.items[index],
                                  style: GoogleFonts.roboto(
                                    fontSize: width * 0.04,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
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

