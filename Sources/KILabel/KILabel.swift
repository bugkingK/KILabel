//
//  KILabel.swift
//  
//
//  Created by Kimun Kwon on 2021/11/23.
//

import UIKit

// TODO: 확인 필요.
public enum KILinkType: Int {
    case userHandle
    case hashTag
    case url
}

// TODO: 확인 필요.
@objc public enum KILinkTypeOption: Int {
    case none = 0
    case userHandle
    case hashTag
    case url
    case all
}

open class KILabel: UILabel {
    /**
     * Enable/disable automatic detection of links, hashtags and usernames.
     */
    @IBInspectable var automaticLinkDetectionEnabled: Bool = true {
        didSet { updateTextStoreWithText() }
    }
    
    /**
     * Specifies the combination of link types to detect. Default value is KILinkTypeAll.
     */
    @IBInspectable var linkDetectionTypes: KILinkTypeOption = .all {
        didSet { updateTextStoreWithText() }
    }
    
    /**
     * Flag sets if the sytem appearance for URLs should be used (underlined + blue color). Default value is NO.
     */
    @IBInspectable var systemURLStyle: Bool = false {
        didSet { text = text }
    }
    
    /**
     * The color used to highlight selected link background.
     *
     * @discussion The default value is (0.95, 0.95, 0.95, 1.0).
     */
    @IBInspectable var selectedLinkBackgroundColor: UIColor = .init(white: 0.95, alpha: 1)
    
    /**
     * Set containing words to be ignored as links, hashtags or usernames.
     *
     * @discussion The comparison between the matches and the ignored words is case insensitive.
     */
    public var ignoredKeywords: Set<String> = .init()
    
    // Used to control layout of glyphs and rendering
    private let layoutManager: NSLayoutManager = .init()
    // Specifies the space in which to render text
    private let textContainer: NSTextContainer = .init()
    // Backing storage for text that is rendered by the layout manager
    private var textStorage: NSTextStorage?
    // Dictionary of detected links and their ranges in the text
    private var linkRanges: [[LinkRangeKey: Any]]?
    // State used to trag if the user has dragged during a touch
    private var isTouchMoved: Bool = false
    // During a touch, range of text that is displayed as selected
    private var selectedRange: NSRange = .init(location: 0, length: 0)
    private var _linkTypeAttributes: [KILinkType: Any] = [:]
    
    enum LinkRangeKey: String {
        case type = "linkType", range, link
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextSystem()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextSystem()
    }
    
    // Common initialisation. Must be done once during construction.
    private func setupTextSystem() {
        // Create a text container and set it up to match our label properties
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        textContainer.size = frame.size
        
        // Create a layout manager for rendering
        layoutManager.delegate = self
        layoutManager.addTextContainer(textContainer)
        // Attach the layou manager to the container and storage
        textContainer.layoutManager = layoutManager
        
        // Make sure user interaction is enabled so we can accept touches
        isUserInteractionEnabled = true
        updateTextStoreWithText()
    }
    
    private func linkAtPoint(location: CGPoint) -> [[LinkRangeKey: Any]]? {
        // Do nothing if we have no text
        guard textStorage?.string.count != 0 else {
            return nil
        }
        
        // Work out the offset of the text in the view
//        let textOffset = calcGlyphsPositionInView()
        
        return []
    }
    // Applies background color to selected range. Used to hilight touched links
    private func setSelectedRange(range: NSRange) {
//        // Remove the current selection if the selection is changing
//        if (self.selectedRange.length && !NSEqualRanges(self.selectedRange, range))
//        {
//            [_textStorage removeAttribute:NSBackgroundColorAttributeName range:self.selectedRange];
//        }
//
//        // Apply the new selection to the text
//        if (range.length && _selectedLinkBackgroundColor != nil)
//        {
//            [_textStorage addAttribute:NSBackgroundColorAttributeName value:_selectedLinkBackgroundColor range:range];
//        }
//
//        // Save the new range
//        _selectedRange = range;
//
//        [self setNeedsDisplay];
    }
    
    open override var numberOfLines: Int {
        didSet { textContainer.maximumNumberOfLines = numberOfLines }
    }
    
    open override var text: String? {
        didSet {
//            if (!text)
//            {
//                text = @"";
//            }
//
//            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self attributesFromProperties]];
//            [self updateTextStoreWithAttributedString:attributedText];
        }
    }
    
    open override var attributedText: NSAttributedString? {
        didSet {
            if let attributedText = attributedText {
                updateTextStoreWithAttributedString(attributedString: attributedText)
            }
        }
    }
    
//    - (NSDictionary*)attributesForLinkType:(KILinkType)linkType
//    {
//        NSDictionary *attributes = _linkTypeAttributes[@(linkType)];
//
//        if (!attributes)
//        {
//            attributes = @{NSForegroundColorAttributeName : self.tintColor};
//        }
//
//        return attributes;
//    }
//
//    - (void)setAttributes:(NSDictionary*)attributes forLinkType:(KILinkType)linkType
//    {
//        if (attributes)
//        {
//            _linkTypeAttributes[@(linkType)] = attributes;
//        }
//        else
//        {
//            [_linkTypeAttributes removeObjectForKey:@(linkType)];
//        }
//
//        // Force refresh text
//        self.text = self.text;
//    }
    
    // MARK: - Text Storage Management
    
    private func updateTextStoreWithText() {
        // Now update our storage from either the attributedString or the plain text
        if let attributedText = attributedText {
            updateTextStoreWithAttributedString(attributedString: attributedText)
        } else if let text = text {
            let attr = NSAttributedString(string: text, attributes: attributesFromProperties())
            updateTextStoreWithAttributedString(attributedString: attr)
        } else {
            let attr = NSAttributedString(string: "", attributes: attributesFromProperties())
            updateTextStoreWithAttributedString(attributedString: attr)
        }
        
        setNeedsDisplay()
    }
    
    private func updateTextStoreWithAttributedString(attributedString: NSAttributedString) {
        var attributedString = attributedString
        if attributedText?.length != 0 {
            attributedString = KILabel.sanitizeAttributedString(attributedString: attributedString)
        }
        
        if automaticLinkDetectionEnabled && attributedString.length != 0 {
            let linkRanges = getRangesForLinks(text: attributedString)
            self.linkRanges = linkRanges
            attributedString = addLinkAttributesToAttributedString(string: attributedString, linkRanges: linkRanges)
        } else {
            linkRanges = nil
        }
        
        if let textStorage = textStorage {
            // Set the string on the storage
            textStorage.setAttributedString(attributedString)
        } else {
            // Create a new text storage and attach it correctly to the layout manager
            textStorage = .init(attributedString: attributedString)
            textStorage?.addLayoutManager(layoutManager)
            layoutManager.textStorage = textStorage
        }
    }
    
    // Returns attributed string attributes based on the text properties set on the label.
    // These are styles that are only applied when NOT using the attributedText directly.
    private func attributesFromProperties() -> [NSAttributedString.Key: Any]? {
        // Setup shadow attributes
        let shadow: NSShadow = .init()
        if let shadowColor = shadowColor {
            shadow.shadowColor = shadowColor
            shadow.shadowOffset = shadowOffset
        } else {
            shadow.shadowColor = nil
            shadow.shadowOffset = .init(width: 0, height: -1)
        }
        
        // Setup color attributes
        var color: UIColor = textColor
        if !isEnabled {
            color = .lightGray
        } else if isHighlighted {
            color = highlightedTextColor ?? textColor
        }
        
        let paragraph: NSMutableParagraphStyle = .init()
        paragraph.alignment = textAlignment
        
        return [.font: font ?? .systemFont(ofSize: 13),
                .foregroundColor: color,
                .shadow: shadow,
                .paragraphStyle: paragraph]
    }
    
    /**
     *  Returns array of ranges for all special words, user handles, hashtags and urls in the specfied
     *  text.
     *
     *  @param text Text to parse for links
     *
     *  @return Array of dictionaries describing the links.
     */
    private func getRangesForLinks(text: NSAttributedString) -> [[LinkRangeKey: Any]] {
        var rangesForLinks: [[LinkRangeKey: Any]] = []
        
        switch linkDetectionTypes {
        case .userHandle:
            rangesForLinks.append(contentsOf: getRangesForUserHandles(text: text.string))
        case .hashTag:
            rangesForLinks.append(contentsOf: getRangesForHashtags(text: text.string))
        case .url:
            if let attributedText = attributedText {
                rangesForLinks.append(contentsOf: getRangesForURLs(text: attributedText))
            }
        default: break
        }
        
        return rangesForLinks
    }
    
    // TODO: 확인필요
    private func getRangesForUserHandles(text: String) -> [[LinkRangeKey: Any]] {
        var rangesForUserHandles: [[LinkRangeKey: Any]] = []
        guard let regex = try? NSRegularExpression(pattern:"(?<!\\w)@([\\w\\_]+)?", options:[]) else {
            return rangesForUserHandles
        }
        // Run the expression and get matches
        let matches = regex.matches(in: text, options: [], range: .init(location: 0, length: text.count))
        // Add all our ranges to the result
        for match in matches {
            guard let matchRange = Range(match.range, in: text) else {
                continue
            }
            let matchString = text.substring(with: matchRange)
            if !ignoreMatch(string: matchString) {
                rangesForUserHandles.append([.type: KILinkType.userHandle,
                                             .range: NSValue(range: match.range),
                                             .link: matchString])
            }
        }
        
        return rangesForUserHandles
    }
    
    // TODO: 확인필요
    private func getRangesForHashtags(text: String) -> [[LinkRangeKey: Any]] {
        var rangesForHashtags: [[LinkRangeKey: Any]] = []
        guard let regex = try? NSRegularExpression(pattern:"(?<!\\w)#([\\w\\_]+)?", options:[]) else {
            return rangesForHashtags
        }
        // Run the expression and get matches
        let matches = regex.matches(in: text, options: [], range: .init(location: 0, length: text.count))
        // Add all our ranges to the result
        for match in matches {
            guard let matchRange = Range(match.range, in: text) else {
                continue
            }
            let matchString = text.substring(with: matchRange)
            if !ignoreMatch(string: matchString) {
                rangesForHashtags.append([.type: KILinkType.hashTag,
                                          .range: NSValue(range: match.range),
                                          .link: matchString])
            }
        }
        
        return rangesForHashtags
    }
    
    // TODO: 확인필요
    private func getRangesForURLs(text: NSAttributedString) -> [[LinkRangeKey: Any]] {
        var rangesForURLs: [[LinkRangeKey: Any]] = []
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return rangesForURLs
        }
        
        let plainText: String = text.string
        let matches = detector.matches(in: plainText, options: [], range: .init(location: 0, length: text.length))
        for match in matches {
            guard let matchRange = Range(match.range, in: plainText) else {
                continue
            }
            var realURL: String = ""
            if let url = text.attribute(.link, at: match.range.location, effectiveRange: nil) as? String {
                realURL = url
            } else {
                realURL = plainText.substring(with: matchRange)
            }
            
            if !ignoreMatch(string: realURL),
               match.resultType == NSTextCheckingResult.CheckingType.link {
                rangesForURLs.append([.type: KILinkType.url,
                                      .range: NSValue(range: match.range),
                                      .link: realURL])
            }
        }
        
        return rangesForURLs
    }
    
    private func ignoreMatch(string: String) -> Bool {
        return ignoredKeywords.contains(string.lowercased())
    }
    
    private func addLinkAttributesToAttributedString(string: NSAttributedString, linkRanges: [[LinkRangeKey: Any]]) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = .init(attributedString: string)
        for dictionary in linkRanges {
            guard let range = dictionary[.range] as? NSRange,
                  let linkType = dictionary[.type] as? KILinkType,
                  let link = dictionary[.link] else {
                continue
            }
            
            // TODO: 사용자 지정이 들어가는 것 같아..
//            NSDictionary *attributes = [self attributesForLinkType:linkType];
//            // Use our tint color to hilight the link
//            [attributedString addAttributes:attributes range:range];
            if systemURLStyle && linkType == KILinkType.url {
                // Add a link attribute using the stored link
                attributedString.addAttribute(.link, value: link, range: range)
            }
        }
        
        return attributedString
    }
}

// MARK: - Layout and Rendering
extension KILabel {
//    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        // Use our text container to calculate the bounds required. First save our
//        // current text container setup
//        CGSize savedTextContainerSize = _textContainer.size;
//        NSInteger savedTextContainerNumberOfLines = _textContainer.maximumNumberOfLines;
//
//        // Apply the new potential bounds and number of lines
//        _textContainer.size = bounds.size;
//        _textContainer.maximumNumberOfLines = numberOfLines;
//
//        // Measure the text with the new state
//        CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
//
//        // Position the bounds and round up the size for good measure
//        textBounds.origin = bounds.origin;
//        textBounds.size.width = ceil(textBounds.size.width);
//        textBounds.size.height = ceil(textBounds.size.height);
//
//        if (textBounds.size.height < bounds.size.height)
//        {
//            // Take verical alignment into account
//            CGFloat offsetY = (bounds.size.height - textBounds.size.height) / 2.0;
//            textBounds.origin.y += offsetY;
//        }
//
//        // Restore the old container state before we exit under any circumstances
//        _textContainer.size = savedTextContainerSize;
//        _textContainer.maximumNumberOfLines = savedTextContainerNumberOfLines;
//
//        return textBounds;
//    }
    
//    open override func drawText(in rect: CGRect) {
//        // Don't call super implementation. Might want to uncomment this out when
//        // debugging layout and rendering problems.
//        // [super drawTextInRect:rect];
//
//        // Calculate the offset of the text in the view
//        NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
//        CGPoint glyphsPosition = [self calcGlyphsPositionInView];
//
//        // Drawing code
//        [_layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:glyphsPosition];
//        [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:glyphsPosition];
//    }
    
//    private func calcGlyphsPositionInView() -> CGPoint {
//        CGPoint textOffset = CGPointZero;
//
//        CGRect textBounds = [_layoutManager usedRectForTextContainer:_textContainer];
//        textBounds.size.width = ceil(textBounds.size.width);
//        textBounds.size.height = ceil(textBounds.size.height);
//
//        if (textBounds.size.height < self.bounds.size.height)
//        {
//            CGFloat paddingHeight = (self.bounds.size.height - textBounds.size.height) / 2.0;
//            textOffset.y = paddingHeight;
//        }
//
//        return textOffset;
//    }
    
    open override var frame: CGRect {
        didSet {
            textContainer.size = bounds.size;
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            textContainer.size = bounds.size;
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = bounds.size;
    }
    
//    private func setIgnoredKeywords(ignoredKeywords: Set) {
//        NSMutableSet *set = [NSMutableSet setWithCapacity:ignoredKeywords.count];
//
//        [ignoredKeywords enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
//            [set addObject:[obj lowercaseString]];
//        }];
//
//        _ignoredKeywords = [set copy];
//    }
}

// MARK: - Interactions
extension KILabel {
//    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        _isTouchMoved = NO;
//
//        // Get the info for the touched link if there is one
//        NSDictionary *touchedLink;
//        CGPoint touchLocation = [[touches anyObject] locationInView:self];
//        touchedLink = [self linkAtPoint:touchLocation];
//
//        if (touchedLink)
//        {
//            self.selectedRange = [[touchedLink objectForKey:KILabelRangeKey] rangeValue];
//        }
//        else
//        {
//            [super touchesBegan:touches withEvent:event];
//        }
//    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        isTouchMoved = true
    }
    
//    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        // If the user dragged their finger we ignore the touch
//        if (_isTouchMoved)
//        {
//            self.selectedRange = NSMakeRange(0, 0);
//
//            return;
//        }
//
//        // Get the info for the touched link if there is one
//        NSDictionary *touchedLink;
//        CGPoint touchLocation = [[touches anyObject] locationInView:self];
//        touchedLink = [self linkAtPoint:touchLocation];
//
//        if (touchedLink)
//        {
//            NSRange range = [[touchedLink objectForKey:KILabelRangeKey] rangeValue];
//            NSString *touchedSubstring = [touchedLink objectForKey:KILabelLinkKey];
//            KILinkType linkType = (KILinkType)[[touchedLink objectForKey:KILabelLinkTypeKey] intValue];
//
//            [self receivedActionForLinkType:linkType string:touchedSubstring range:range];
//        }
//        else
//        {
//            [super touchesBegan:touches withEvent:event];
//        }
//
//        self.selectedRange = NSMakeRange(0, 0);
//    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        selectedRange = .init(location: 0, length: 0)
    }
    
//    - (void)receivedActionForLinkType:(KILinkType)linkType string:(NSString*)string range:(NSRange)range
//    {
//        switch (linkType)
//        {
//        case KILinkTypeUserHandle:
//            if (_userHandleLinkTapHandler)
//            {
//                _userHandleLinkTapHandler(self, string, range);
//            }
//            break;
//
//        case KILinkTypeHashtag:
//            if (_hashtagLinkTapHandler)
//            {
//                _hashtagLinkTapHandler(self, string, range);
//            }
//            break;
//
//        case KILinkTypeURL:
//            if (_urlLinkTapHandler)
//            {
//                _urlLinkTapHandler(self, string, range);
//            }
//            break;
//        }
//    }
}

extension KILabel: NSLayoutManagerDelegate {
//    public func layoutManager(_ layoutManager: NSLayoutManager, shouldBreakLineByWordBeforeCharacterAt charIndex: Int) -> Bool {
//        // Don't allow line breaks inside URLs
//        NSRange range;
//        NSURL *linkURL = [layoutManager.textStorage attribute:NSLinkAttributeName atIndex:charIndex effectiveRange:&range];
//
//        return !(linkURL && (charIndex > range.location) && (charIndex <= NSMaxRange(range)));
//    }
    
    // TODO: 확인 필요.
    static func sanitizeAttributedString(attributedString: NSAttributedString) -> NSAttributedString {
        // Setup paragraph alignement properly. IB applies the line break style
        // to the attributed string. The problem is that the text container then
        // breaks at the first line of text. If we set the line break to wrapping
        // then the text container defines the break mode and it works.
        // NOTE: This is either an Apple bug or something I've misunderstood.
        
        // Get the current paragraph style. IB only allows a single paragraph so
        // getting the style of the first char is fine.
        var range: NSRange = .init()
        let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: &range)
        
        guard let paragraphStyle = paragraphStyle as? NSParagraphStyle else {
            return attributedString
        }
        
        // Remove the line breaks
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.setParagraphStyle(paragraphStyle)
        mutableParagraphStyle.lineBreakMode = .byWordWrapping
        
        // Apply new style
        let restyled: NSMutableAttributedString = .init(attributedString: attributedString)
        restyled.addAttributes([.paragraphStyle: mutableParagraphStyle], range: .init(location: 0, length: restyled.length))
        return restyled
    }
}
