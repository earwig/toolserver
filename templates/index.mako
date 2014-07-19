<%!
    from flask import g, request
    from copyvios.checker import T_POSSIBLE, T_SUSPECT
%>\
<%include file="/support/header.mako" args="title='Earwig\'s Copyvio Detector'"/>
<%namespace module="copyvios.highlighter" import="highlight_delta"/>\
<%namespace module="copyvios.misc" import="httpsfix, urlstrip"/>\
% if query.project and query.lang and (query.title or query.oldid):
    % if query.error == "bad URI":
        <div id="info-box" class="red-box">
            <p>Unsupported URI scheme: <a href="${query.url | h}">${query.url | h}</a>.</p>
        </div>
    % elif query.error == "no data":
        <div id="info-box" class="red-box">
            <p>Couldn't find any text in <a href="${query.url | h}">${query.url | h}</a>. <i>Note:</i> only HTML and plain text pages are supported, and content generated by JavaScript or found inside iframes is ignored.</p>
        </div>
    % elif query.error == "timeout":
        <div id="info-box" class="red-box">
            <p>The URL <a href="${query.url | h}">${query.url | h}</a> timed out before any data could be retrieved.</p>
        </div>
    % elif not query.site:
        <div id="info-box" class="red-box">
            <p>The given site (project=<b><span class="mono">${query.project | h}</span></b>, language=<b><span class="mono">${query.lang | h}</span></b>) doesn't seem to exist. It may also be closed or private. <a href="//${query.lang | h}.${query.project | h}.org/">Confirm its URL.</a></p>
        </div>
    % elif query.title and not result:
        <div id="info-box" class="red-box">
            <p>The given page doesn't seem to exist: <a href="${query.page.url}">${query.page.title | h}</a>.</p>
        </div>
    % elif query.oldid and not result:
        <div id="info-box" class="red-box">
            <p>The given revision ID doesn't seem to exist: <a href="//${query.site.domain | h}/w/index.php?oldid=${query.oldid | h}">${query.oldid | h}</a>.</p>
        </div>
    % endif
%endif
<p>This tool attempts to detect <a href="//en.wikipedia.org/wiki/WP:COPYVIO">copyright violations</a> in articles. Simply give the title of the page or ID of the revision you want to check and hit Submit. The tool will search for similar content elsewhere on the web using <a href="//info.yahoo.com/legal/us/yahoo/boss/pricing/">Yahoo! BOSS</a> and then display a report if a match is found. If you give a URL, it will skip the search engine step and directly display a report comparing the article to that particular webpage, like the <a href="//toolserver.org/~dcoetzee/duplicationdetector/">Duplication Detector</a>.</p>
<p>Specific websites can be excluded from the check (for example, if their content is in the public domain) by being added to the <a href="//en.wikipedia.org/wiki/User:EarwigBot/Copyvios/Exclusions">excluded URL list</a>.</p>
<form action="${request.script_root}" method="get">
    <table id="cv-form">
        <tr>
            <td>Site:</td>
            <td colspan="3">
                <span class="mono">http://</span>
                <select name="lang">
                    <% selected_lang = query.orig_lang if query.orig_lang else g.cookies["CopyviosDefaultLang"].value if "CopyviosDefaultLang" in g.cookies else g.bot.wiki.get_site().lang %>\
                    % for code, name in query.all_langs:
                        % if code == selected_lang:
                            <option value="${code | h}" selected="selected">${name}</option>
                        % else:
                            <option value="${code | h}">${name}</option>
                        % endif
                    % endfor
                </select>
                <span class="mono">.</span>
                <select name="project">
                    <% selected_project = query.project if query.project else g.cookies["CopyviosDefaultProject"].value if "CopyviosDefaultProject" in g.cookies else g.bot.wiki.get_site().project %>\
                    % for code, name in query.all_projects:
                        % if code == selected_project:
                            <option value="${code | h}" selected="selected">${name}</option>
                        % else:
                            <option value="${code | h}">${name}</option>
                        % endif
                    % endfor
                </select>
                <span class="mono">.org</span>
            </td>
        </tr>
        <tr>
            <td id="cv-col1">Page&nbsp;title:</td>
            <td id="cv-col2">
                % if query.title:
                    <input class="cv-text" type="text" name="title" value="${query.page.title if query.page else query.title | h}" />
                % else:
                    <input class="cv-text" type="text" name="title" />
                % endif
            </td>
            <td id="cv-col3">or&nbsp;revision&nbsp;ID:</td>
            <td id="cv-col4">
                % if query.oldid:
                    <input class="cv-text" type="text" name="oldid" value="${query.oldid | h}" />
                % else:
                    <input class="cv-text" type="text" name="oldid" />
                % endif
            </td>
        </tr>
        <tr>
            <td>URL&nbsp;(optional):</td>
            <td colspan="3">
                % if query.url:
                    <input class="cv-text" type="text" name="url" value="${query.url | h}" />
                % else:
                    <input class="cv-text" type="text" name="url" />
                % endif
            </td>
        </tr>
        % if query.nocache or (result and result.cached):
            <tr>
                <td>Bypass&nbsp;cache:</td>
                <td colspan="3">
                    % if query.nocache:
                        <input type="checkbox" name="nocache" value="1" checked="checked" />
                    % else:
                        <input type="checkbox" name="nocache" value="1" />
                    % endif
                </td>
            </tr>
        % endif
        <tr>
            <td colspan="4">
                <button type="submit">Submit</button>
            </td>
        </tr>
    </table>
</form>
% if result:
    <% hide_comparison = "CopyviosHideComparison" in g.cookies and g.cookies["CopyviosHideComparison"].value == "True" %>
    <div class="divider"></div>
    <div id="cv-result" class="${'red' if result.confidence >= T_SUSPECT else 'yellow' if result.confidence >= T_POSSIBLE else 'green'}-box">
        <h2 id="cv-result-header">
            % if result.confidence >= T_POSSIBLE:
                <a href="${query.page.url}">${query.page.title | h}</a>
                % if query.oldid:
                    @<a href="//${query.site.domain | h}/w/index.php?oldid=${query.oldid | h}">${query.oldid | h}</a>
                % endif
                is a ${"suspected" if result.confidence >= T_SUSPECT else "possible"} violation of <a href="${result.url | h}">${result.url | urlstrip, h}</a>.
            % else:
                % if query.oldid:
                    No violations detected in <a href="${query.page.url}">${query.page.title | h}</a> @<a href="//${query.site.domain | h}/w/index.php?oldid=${query.oldid | h}">${query.oldid | h}</a>.
                % else:
                    No violations detected in <a href="${query.page.url}">${query.page.title | h}</a>.
                % endif
            % endif
        </h2>
        <ul id="cv-result-list">
            % if result.confidence < T_POSSIBLE and not query.url:
                % if result.url:
                    <li>Best match: <a href="${result.url | h}">${result.url | urlstrip, h}</a>.</li>
                % else:
                    <li>No matches found.</li>
                % endif
            % endif
            % if result.url:
                <li><b><span class="mono">${round(result.confidence * 100, 1)}%</span></b> confidence of a violation.</li>
            % endif
            % if query.redirected_from:
                <li>Redirected from <a href="${query.redirected_from.url}">${query.redirected_from.title | h}</a>. <a href="${request.url | httpsfix, h}&amp;noredirect=1">Check the original page.</a></li>
            % endif
            % if result.cached:
                <li>
                    Results are <a id="cv-cached" href="#">cached<span>To save time (and money), this tool will retain the results of checks for up to 72 hours. This includes the URL of the "violated" source, but neither its content nor the content of the article. Future checks on the same page (assuming it remains unchanged) will not involve additional search queries, but a fresh comparison against the source URL will be made. If the page is modified, a new check will be run.</span></a> from <abbr title="${result.cache_time}">${result.cache_age} ago</abbr>. Retrieved in <span class="mono">${round(result.time, 3)}</span> seconds (originally generated in
                    % if result.queries:
                        <span class="mono">${round(result.original_time, 3)}</span>s using <span class="mono">${result.queries}</span> queries).
                    % else:
                        <span class="mono">${round(result.original_time, 3)}</span>s).
                    % endif
                    <a href="${request.url | httpsfix, h}&amp;nocache=1">Bypass the cache.</a>
                </li>
            % else:
                <li>Results generated in <span class="mono">${round(result.time, 3)}</span> seconds using <span class="mono">${result.queries}</span> queries.</li>
            % endif
            % if result.queries:
                <li><i>Fun fact:</i> The Wikimedia Foundation paid Yahoo! Inc. <a href="http://info.yahoo.com/legal/us/yahoo/search/bosspricing/details.html">$${result.queries * 0.0008} USD</a> for these results.</li>
            % endif
            <li><a id="cv-chain-link" href="#cv-chain-table" onclick="copyvio_toggle_details()">${"Show" if hide_comparison else "Hide"} comparison:</a></li>
        </ul>
        <table id="cv-chain-table" style="display: ${'none' if hide_comparison else 'table'};">
            <tr>
                <td class="cv-chain-cell">Article: <div class="cv-chain-detail"><p>${highlight_delta(result.article_chain, result.delta_chain)}</p></div></td>
                <td class="cv-chain-cell">Source: <div class="cv-chain-detail"><p>${highlight_delta(result.source_chain, result.delta_chain)}</p></div></td>
            </tr>
        </table>
    </div>
% endif
<%include file="/support/footer.mako"/>
